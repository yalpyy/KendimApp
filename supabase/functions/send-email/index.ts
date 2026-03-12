// Kendin — Email Sending Edge Function (via Resend)
//
// Sends transactional emails using Resend API.
// IMPORTANT: RESEND_API_KEY must be set as a Supabase secret.
//   supabase secrets set RESEND_API_KEY=re_xxxxx
//
// Supported modes:
//   1. Single:    { email_type, to_email, to_name }
//   2. Broadcast: { broadcast: true, audience: "all"|"premium"|"free", subject, body }
//
// Supported email types (single mode):
//   - welcome, premium_activated, premium_expired
//
// This function NEVER exposes the Resend API key to the client.
// Deploy: supabase functions deploy send-email

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Email templates — simple inline HTML for now.
// Replace with Resend template IDs in production if preferred.
const templates: Record<string, { subject: string; html: (name: string) => string }> = {
  welcome: {
    subject: 'Kendin\'e Hoş Geldin',
    html: (name: string) => `
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; max-width: 480px; margin: 0 auto; padding: 40px 24px; color: #1a1a1a;">
        <h2 style="font-weight: 500; font-size: 20px; margin-bottom: 8px;">Merhaba${name ? `, ${name}` : ''}.</h2>
        <p style="color: #666; line-height: 1.6; font-size: 15px;">
          Kendin'e hoş geldin. Her gün kendine bir soru soruyoruz. Cevap vermek zorunda değilsin.
          Ama yazarsan, haftanın sonunda kendinle karşılaşırsın.
        </p>
        <p style="color: #999; font-size: 13px; margin-top: 32px;">— Kendin</p>
      </div>
    `,
  },
  premium_activated: {
    subject: 'Derinlik Aktif',
    html: (name: string) => `
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; max-width: 480px; margin: 0 auto; padding: 40px 24px; color: #1a1a1a;">
        <h2 style="font-weight: 500; font-size: 20px; margin-bottom: 8px;">Derinlik açıldı${name ? `, ${name}` : ''}.</h2>
        <p style="color: #666; line-height: 1.6; font-size: 15px;">
          Artık eksik günleri tamamlayabilir, yansımalarını arşivleyebilir ve geçmiş haftalara dönebilirsin.
          Daha derin bir bakış.
        </p>
        <p style="color: #999; font-size: 13px; margin-top: 32px;">— Kendin</p>
      </div>
    `,
  },
  premium_expired: {
    subject: 'Derinlik Süresi Doldu',
    html: (name: string) => `
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; max-width: 480px; margin: 0 auto; padding: 40px 24px; color: #1a1a1a;">
        <h2 style="font-weight: 500; font-size: 20px; margin-bottom: 8px;">Merhaba${name ? `, ${name}` : ''}.</h2>
        <p style="color: #666; line-height: 1.6; font-size: 15px;">
          Derinlik aboneliğin sona erdi. Yansımalarına hâlâ erişebilirsin ama yeni haftalarda
          eksik gün tamamlama ve arşivleme özellikleri kullanılamaz.
        </p>
        <p style="color: #666; line-height: 1.6; font-size: 15px;">
          İstersen Derinlik'i yeniden açabilirsin.
        </p>
        <p style="color: #999; font-size: 13px; margin-top: 32px;">— Kendin</p>
      </div>
    `,
  },
}

function wrapHtml(subject: string, body: string): string {
  return `
    <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; max-width: 480px; margin: 0 auto; padding: 40px 24px; color: #1a1a1a;">
      <h2 style="font-weight: 500; font-size: 20px; margin-bottom: 16px;">${subject}</h2>
      <div style="color: #666; line-height: 1.6; font-size: 15px; white-space: pre-line;">${body}</div>
      <p style="color: #999; font-size: 13px; margin-top: 32px;">— Kendin</p>
    </div>
  `
}

async function sendOne(apiKey: string, to: string, subject: string, html: string): Promise<boolean> {
  try {
    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${apiKey}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ from: 'Kendin <noreply@kendin.app>', to: [to], subject, html }),
    })
    return res.ok
  } catch {
    return false
  }
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const resendApiKey = Deno.env.get('RESEND_API_KEY')
    if (!resendApiKey) {
      throw new Error('RESEND_API_KEY is not configured')
    }

    const payload = await req.json()

    // ─── Broadcast mode ─────────────────────────────
    if (payload.broadcast === true) {
      const { audience, subject, body } = payload
      if (!audience || !subject || !body) {
        return new Response(
          JSON.stringify({ error: 'Missing audience, subject, or body' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
        )
      }

      const supabaseUrl = Deno.env.get('SUPABASE_URL')!
      const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
      const supabase = createClient(supabaseUrl, supabaseServiceKey)

      // Query users based on audience
      let query = supabase.from('users').select('id, display_name, is_premium')
      if (audience === 'premium') query = query.eq('is_premium', true)
      else if (audience === 'free') query = query.eq('is_premium', false)

      const { data: users, error: usersError } = await query
      if (usersError) throw new Error(`Failed to fetch users: ${usersError.message}`)

      // Get emails from auth.users
      const { data: { users: authUsers }, error: authError } = await supabase.auth.admin.listUsers({ perPage: 1000 })
      if (authError) throw new Error(`Failed to fetch auth users: ${authError.message}`)

      const emailMap = new Map<string, string>()
      for (const au of authUsers) {
        if (au.email) emailMap.set(au.id, au.email)
      }

      const html = wrapHtml(subject, body)
      let sent = 0
      let failed = 0

      for (const user of users || []) {
        const email = emailMap.get(user.id)
        if (!email) continue
        const ok = await sendOne(resendApiKey, email, subject, html)
        if (ok) sent++
        else failed++
      }

      return new Response(
        JSON.stringify({ success: true, sent, failed, total: (users || []).length }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    // ─── Single email mode ──────────────────────────
    const { email_type, to_email, to_name } = payload

    if (!email_type || !to_email) {
      return new Response(
        JSON.stringify({ error: 'Missing email_type or to_email' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const template = templates[email_type]
    if (!template) {
      return new Response(
        JSON.stringify({ error: `Unknown email_type: ${email_type}` }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Send via Resend API
    const resendResponse = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${resendApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'Kendin <noreply@kendin.app>',
        to: [to_email],
        subject: template.subject,
        html: template.html(to_name || ''),
      }),
    })

    if (!resendResponse.ok) {
      const errorText = await resendResponse.text()
      throw new Error(`Resend API error: ${errorText}`)
    }

    const result = await resendResponse.json()

    return new Response(
      JSON.stringify({ success: true, id: result.id }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
