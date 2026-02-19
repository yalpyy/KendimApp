// Kendin — Weekly Reflection Edge Function
//
// Triggered by the Flutter app when a user requests their
// Sunday reflection. Fetches the week's entries, generates
// a calm observational reflection via OpenAI, and stores it.
//
// Deploy: supabase functions deploy generate-reflection

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
    const { user_id, week_start_date } = await req.json()

    if (!user_id || !week_start_date) {
      return new Response(
        JSON.stringify({ error: 'Missing user_id or week_start_date' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Initialize Supabase client with service role for full access.
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const openaiApiKey = Deno.env.get('OPENAI_API_KEY')!

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Fetch week's entries (Mon–Sat).
    const weekStart = new Date(week_start_date)
    const weekEnd = new Date(weekStart)
    weekEnd.setDate(weekEnd.getDate() + 5) // Through Saturday

    const { data: entries, error: entriesError } = await supabase
      .from('entries')
      .select('text, created_at')
      .eq('user_id', user_id)
      .gte('created_at', weekStart.toISOString())
      .lte('created_at', weekEnd.toISOString())
      .order('created_at')

    if (entriesError) {
      throw new Error(`Failed to fetch entries: ${entriesError.message}`)
    }

    if (!entries || entries.length === 0) {
      return new Response(
        JSON.stringify({ error: 'No entries found for this week' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Check if user is premium (for deeper reflection).
    const { data: userData } = await supabase
      .from('users')
      .select('is_premium')
      .eq('id', user_id)
      .single()

    const isPremium = userData?.is_premium ?? false

    // Format entries for the prompt.
    const entriesText = entries
      .map((e: { text: string; created_at: string }) => {
        const date = new Date(e.created_at).toLocaleDateString('tr-TR', {
          weekday: 'long',
          day: 'numeric',
          month: 'long',
        })
        return `${date}: ${e.text}`
      })
      .join('\n\n')

    // Build the AI prompt.
    const systemPrompt = `Sen sakin bir yansıma yazarısın.
Tavsiye verme.
Eylem önerme.
Yargılama.
Motive etme.
Türkçe yaz.
Ton: yumuşak, gözlemsel.
${isPremium ? 'Biraz daha derin ve kişisel bir gözlem yap.' : ''}
Bir mektup gibi hissettir.`

    const userPrompt = `İşte bu haftanın günlük yazıları:

${entriesText}

3-4 cümlelik haftalık yansıma yaz.`

    // Call OpenAI API.
    const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openaiApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userPrompt },
        ],
        max_tokens: 300,
        temperature: 0.7,
      }),
    })

    if (!openaiResponse.ok) {
      const errorText = await openaiResponse.text()
      throw new Error(`OpenAI API error: ${errorText}`)
    }

    const aiResult = await openaiResponse.json()
    const reflectionContent = aiResult.choices[0]?.message?.content?.trim()

    if (!reflectionContent) {
      throw new Error('Empty reflection from AI')
    }

    // Store the reflection.
    const { error: insertError } = await supabase
      .from('weekly_reflections')
      .upsert({
        user_id,
        week_start_date,
        content: reflectionContent,
        is_archived: false,
      }, {
        onConflict: 'user_id,week_start_date',
      })

    if (insertError) {
      throw new Error(`Failed to store reflection: ${insertError.message}`)
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
