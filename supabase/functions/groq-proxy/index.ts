import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const GROQ_URL = "https://api.groq.com/openai/v1/chat/completions";
const GROQ_MODEL = "meta-llama/llama-4-scout-17b-16e-instruct";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const PROMPTS: Record<string, string> = {
  sia:
    "This is an SIA (Security Industry Authority) licence card.\n" +
    "Extract exactly:\n" +
    "1. Licence number — 16 digits formatted as XXXX XXXX XXXX XXXX\n" +
    "2. Expiry date — formatted as DD MMM YYYY e.g. 19 JUN 2028\n" +
    "3. Holder name — initial + surname at bottom left e.g. T. DALAL\n\n" +
    'Reply ONLY with valid JSON, no markdown fences:\n{"documentNumber":"...","expiryDate":"...","holderName":"..."}',

  act:
    "This is an ACT (Action Counters Terrorism) Awareness e-Learning certificate.\n" +
    "Extract exactly:\n" +
    "1. Holder name — the full name printed in bold near the top e.g. Arman Khan\n" +
    "2. Date of completion — printed as DD.MM.YYYY e.g. 19.10.2025\n\n" +
    'Reply ONLY with valid JSON, no markdown fences:\n{"holderName":"...","completionDate":"..."}',

  firstaid:
    "This is a First Aid at Work Awareness certificate.\n" +
    "Extract exactly:\n" +
    "1. Holder name — the full name in bold near the top e.g. ARMAN KHAN\n" +
    "2. Awarded date — the date next to the AWARDED label e.g. 2 December 2025\n" +
    "3. Certificate number — the number next to CERTIFICATE NUMBER label e.g. 1002855-176-463-3892\n" +
    "4. Centre — the code next to CENTRE label e.g. MT56BA\n\n" +
    'Reply ONLY with valid JSON, no markdown fences:\n{"holderName":"...","awardedDate":"...","certificateNumber":"...","centre":"..."}',

  sharecode:
    "This is a UK 'Prove your right to work' Share Code document.\n" +
    "Extract exactly:\n" +
    "1. Share code — 3 groups of letters/numbers separated by spaces e.g. WHH SBK 6PT\n" +
    "2. Valid until date — the expiry date of the code e.g. 18 January 2026\n\n" +
    'Reply ONLY with valid JSON, no markdown fences:\n{"shareCode":"...","validUntil":"..."}',
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // ── Read raw bytes and decode manually — works regardless of Content-Type ──
    const buffer = await req.arrayBuffer();
    const rawText = new TextDecoder().decode(buffer);

    let parsed: Record<string, unknown>;
    try {
      const first = JSON.parse(rawText);
      // Handle double-encoded string case
      parsed = typeof first === "string" ? JSON.parse(first) : first;
    } catch {
      return new Response(
        JSON.stringify({ error: "JSON parse failed", received: rawText.substring(0, 100) }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const imageBase64 = parsed["imageBase64"] as string | undefined;
    const mimeType    = parsed["mimeType"]    as string | undefined;
    const certType    = parsed["certType"]    as string | undefined;

    if (!imageBase64 || !mimeType || !certType) {
      return new Response(
        JSON.stringify({
          error: "Missing imageBase64, mimeType, or certType",
          receivedKeys: Object.keys(parsed),
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const prompt = PROMPTS[certType];
    if (!prompt) {
      return new Response(
        JSON.stringify({ error: `Unknown certType: ${certType}` }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const groqKey = Deno.env.get("GROQ_API_KEY");
    if (!groqKey) throw new Error("GROQ_API_KEY not configured");

    const groqResponse = await fetch(GROQ_URL, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${groqKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: GROQ_MODEL,
        max_tokens: 256,
        temperature: 0,
        messages: [
          {
            role: "user",
            content: [
              {
                type: "image_url",
                image_url: { url: `data:${mimeType};base64,${imageBase64}` },
              },
              { type: "text", text: prompt },
            ],
          },
        ],
      }),
    });

    if (!groqResponse.ok) {
      const errBody = await groqResponse.text();
      throw new Error(`Groq API error ${groqResponse.status}: ${errBody}`);
    }

    const data = await groqResponse.json();
    const raw = data.choices[0].message.content as string;
    const cleaned = raw.replaceAll("```json", "").replaceAll("```", "").trim();
    const result = JSON.parse(cleaned);

    return new Response(
      JSON.stringify({ ...result, fullText: cleaned }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (e) {
    return new Response(
      JSON.stringify({ error: (e as Error).message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});