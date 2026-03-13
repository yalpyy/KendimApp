import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

/**
 * send-push — Send push notifications to users via FCM HTTP v1 API.
 *
 * Modes:
 * 1. Single: { user_id, title, body }
 * 2. Broadcast: { broadcast: true, audience: "all"|"premium"|"free", title, body }
 *
 * Requires:
 * - FCM_SERVER_KEY: Firebase Cloud Messaging server key (legacy or v1)
 *   Set via: supabase secrets set FCM_SERVER_KEY=your-key
 */
serve(async (req: Request) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const fcmServerKey = Deno.env.get("FCM_SERVER_KEY");
    if (!fcmServerKey) {
      return new Response(
        JSON.stringify({ error: "FCM_SERVER_KEY not configured" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const payload = await req.json();
    const { broadcast, audience, user_id, title, body } = payload;

    if (!title || !body) {
      return new Response(
        JSON.stringify({ error: "title and body are required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    let tokens: string[] = [];

    if (broadcast) {
      // Fetch tokens based on audience
      let query = supabase.from("device_tokens").select("token, user_id");

      if (audience === "premium" || audience === "free") {
        // Get user IDs matching audience
        const isPremium = audience === "premium";
        const { data: users } = await supabase
          .from("users")
          .select("id")
          .eq("is_premium", isPremium);

        const userIds = (users || []).map((u: any) => u.id);
        if (userIds.length === 0) {
          return new Response(
            JSON.stringify({ sent: 0, failed: 0, message: "No matching users" }),
            {
              status: 200,
              headers: { ...corsHeaders, "Content-Type": "application/json" },
            }
          );
        }

        query = query.in_("user_id", userIds);
      }

      const { data: tokenData, error: tokenError } = await query;
      if (tokenError) throw tokenError;

      tokens = (tokenData || []).map((t: any) => t.token);
    } else if (user_id) {
      // Single user
      const { data: tokenData } = await supabase
        .from("device_tokens")
        .select("token")
        .eq("user_id", user_id);

      tokens = (tokenData || []).map((t: any) => t.token);
    }

    if (tokens.length === 0) {
      return new Response(
        JSON.stringify({ sent: 0, failed: 0, message: "No device tokens found" }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Send via FCM legacy HTTP API
    let sent = 0;
    let failed = 0;
    const staleTokens: string[] = [];

    // Send in batches of 500 (FCM limit)
    const batchSize = 500;
    for (let i = 0; i < tokens.length; i += batchSize) {
      const batch = tokens.slice(i, i + batchSize);

      const fcmPayload = {
        registration_ids: batch,
        notification: {
          title: title,
          body: body,
          sound: "default",
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          type: "admin_broadcast",
        },
      };

      const fcmResponse = await fetch(
        "https://fcm.googleapis.com/fcm/send",
        {
          method: "POST",
          headers: {
            Authorization: `key=${fcmServerKey}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify(fcmPayload),
        }
      );

      const fcmResult = await fcmResponse.json();

      if (fcmResult.results) {
        fcmResult.results.forEach((result: any, index: number) => {
          if (result.message_id) {
            sent++;
          } else {
            failed++;
            // Track stale/invalid tokens for cleanup
            if (
              result.error === "NotRegistered" ||
              result.error === "InvalidRegistration"
            ) {
              staleTokens.push(batch[index]);
            }
          }
        });
      }
    }

    // Clean up stale tokens
    if (staleTokens.length > 0) {
      await supabase
        .from("device_tokens")
        .delete()
        .in_("token", staleTokens);
    }

    return new Response(
      JSON.stringify({ sent, failed, cleaned: staleTokens.length }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("send-push error:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
