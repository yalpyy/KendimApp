// Kendin — Email Sending Edge Function (via Resend)
//
// Sends transactional emails using Resend API.
// IMPORTANT: RESEND_API_KEY must be set as a Supabase secret.
//   supabase secrets set RESEND_API_KEY=re_xxxxx
//
// Supported email types:
//   - welcome: sent after first email account creation
//   - premium_activated: sent when premium subscription starts
//   - premium_expired: sent when premium subscription expires
//
// This function NEVER exposes the Resend API key to the client.
// Deploy: supabase functions deploy send-email

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'

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

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const resendApiKey = Deno.env.get('RESEND_API_KEY')
    if (!resendApiKey) {
      throw new Error('RESEND_API_KEY is not configured')
    }

    const { email_type, to_email, to_name } = await req.json()

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
