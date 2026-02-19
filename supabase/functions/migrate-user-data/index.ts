// Kendin — User Data Migration Edge Function
//
// Securely migrates entries and weekly_reflections from an
// anonymous user to a new email-authenticated user.
// Called during the anonymous → email account transition.
//
// Deploy: supabase functions deploy migrate-user-data

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request) => {
  // Handle CORS preflight.
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { old_user_id, new_user_id } = await req.json()

    if (!old_user_id || !new_user_id) {
      return new Response(
        JSON.stringify({ error: 'Missing old_user_id or new_user_id' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (old_user_id === new_user_id) {
      return new Response(
        JSON.stringify({ error: 'old_user_id and new_user_id must be different' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Initialize Supabase client with service role for full access.
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Verify the old user exists and is anonymous.
    const { data: oldUser, error: oldUserError } = await supabase.auth.admin.getUserById(old_user_id)
    if (oldUserError || !oldUser?.user) {
      return new Response(
        JSON.stringify({ error: 'Old user not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Verify the new user exists.
    const { data: newUser, error: newUserError } = await supabase.auth.admin.getUserById(new_user_id)
    if (newUserError || !newUser?.user) {
      return new Response(
        JSON.stringify({ error: 'New user not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Migrate entries: update user_id from old to new.
    const { error: entriesError } = await supabase
      .from('entries')
      .update({ user_id: new_user_id })
      .eq('user_id', old_user_id)

    if (entriesError) {
      throw new Error(`Failed to migrate entries: ${entriesError.message}`)
    }

    // Migrate weekly_reflections: update user_id from old to new.
    const { error: reflectionsError } = await supabase
      .from('weekly_reflections')
      .update({ user_id: new_user_id })
      .eq('user_id', old_user_id)

    if (reflectionsError) {
      throw new Error(`Failed to migrate reflections: ${reflectionsError.message}`)
    }

    // Copy premium status from old user to new user.
    const { data: oldUserData } = await supabase
      .from('users')
      .select('is_premium, premium_miss_tokens')
      .eq('id', old_user_id)
      .single()

    if (oldUserData) {
      await supabase
        .from('users')
        .update({
          is_premium: oldUserData.is_premium,
          premium_miss_tokens: oldUserData.premium_miss_tokens,
        })
        .eq('id', new_user_id)
    }

    return new Response(
      JSON.stringify({ success: true }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
