import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

// ============================================================================
// تعبیر خواب هوشمند کواکب
// ============================================================================
// معماری: این فانکشن فعلاً فقط از منبع «تعبیر سنتی فارسی» استفاده می‌کند.
// برای افزودن منابع دیگر در آینده (اسلامی، روان‌شناختی)، کافی است یک
// SOURCE_PROMPTS جدید تعریف شود و بر اساس پارامتر ورودی «source» انتخاب شود.
// فعلاً فقط "traditional-fa" فعال است.

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// ---- دیتای مرجع موجود پروژه (کپی سبک از dream_data.dart سمت Flutter) ----
// این لیست کوتاه‌شده فقط برای «راهنمایی و زمینه‌سازی» به مدل داده می‌شود؛
// مدل موظف است بر اساس متن واقعی خواب کاربر تعبیر یکپارچه بسازد، نه اینکه
// این توضیحات را عیناً کپی کند.
const REFERENCE_SYMBOLS: Record<string, string> = {
  "مار": "نشانه‌ی دشمنی پنهان یا خطر ناشناخته؛ کشتن مار در خواب نشانه‌ی غلبه بر دشمن است.",
  "آب": "آب زلال نشانه‌ی آرامش و برکت؛ آب گل‌آلود نشانه‌ی آشفتگی درونی است.",
  "پرواز": "نشانه‌ی آزادی، رهایی از محدودیت یا موفقیتی نزدیک.",
  "افتادن": "بازتاب اضطراب یا از دست دادن کنترل بر یک موقعیت.",
  "مرگ": "معمولاً نشانه‌ی پایان یک دوره و آغاز مرحله‌ای تازه است، نه خبر بد واقعی.",
  "عروسی": "نشانه‌ی تعهد یا آغاز پیمانی تازه، نه لزوماً ازدواج واقعی.",
  "پول": "نشانه‌ی احساس ارزشمندی یا فرصت تازه.",
  "گم شدن": "نشانه‌ی سردرگمی درباره‌ی مسیر زندگی یا تصمیمی معلق.",
  "حاملگی": "نمادی از آغاز یک پروژه یا ایده‌ی تازه در حال شکل‌گیری.",
  "آتش": "هم می‌تواند نماد خشم/نابودی باشد و هم پاکسازی و انرژی تازه.",
  "خانه": "نماد خود واقعی و درونی شخص.",
  "دندان": "نگرانی درباره‌ی ظاهر، سن یا از دست دادن اعتبار.",
  "دریا": "دریای آرام یعنی آرامش درونی؛ دریای طوفانی یعنی احساسات سرکوب‌شده.",
  "گربه": "استقلال، غریزه یا گاهی دورویی کسی در اطراف.",
  "سگ": "وفاداری و دوستی؛ سگ خشمگین هشداری درباره‌ی یک رابطه است.",
};

function findReferenceContext(dreamText: string): string {
  const matches: string[] = [];
  for (const [keyword, meaning] of Object.entries(REFERENCE_SYMBOLS)) {
    if (dreamText.includes(keyword) && matches.length < 8) {
      matches.push(`- ${keyword}: ${meaning}`);
    }
  }
  return matches.length > 0 ? matches.join("\n") : "(هیچ نمادِ از پیش‌تعریف‌شده‌ای در متن پیدا نشد)";
}

const SOURCE_PROMPTS: Record<string, string> = {
  "traditional-fa": `تو یک تعبیرگر خواب حرفه‌ای، مرموز و شیک به سبک تعبیرهای سنتی فارسی هستی که برای اپ «کواکب» کار می‌کنی.

وظیفه‌ات این است که خواب آزاد کاربر را بخوانی، عناصر مهمش (افراد، حیوانات، اشیا، مکان‌ها، رنگ‌ها، اتفاقات، احساس خواب‌بین، فضای خواب، ارتباط بین عناصر، پایان خواب) را در ذهن استخراج کنی، و بر همین اساس یک تعبیر یکپارچه (نه فقط معنی تک‌تک کلمات پشت‌سرهم) بسازی.

نکات حیاتی:
- ترکیب نمادها مهم است: مثلاً «مار سفید» با «مار سیاه» یا «فرار از مار» یا «کشتن مار» باید تعبیر متفاوتی داشته باشند، نه یک تعبیر ثابت برای «مار».
- اگر خواب کوتاه و مبهم بود، از خودت چیزی نساز؛ تعبیر را کوتاه و با عبارت‌های محتاطانه بده.
- هرگز قطعی حرف نزن. همیشه از عبارت‌هایی مثل «می‌تواند نشانه‌ی ... باشد»، «در تعبیرهای سنتی ...»، «ممکن است نماد ... باشد» استفاده کن.
- لحن: جذاب، مرموز، لوکس، روان، داستانی، ولی حرفه‌ای — نه ترسناک و نه ادعای پیشگویی قطعی.
- فقط بخش‌هایی را پر کن که واقعاً از متن خواب قابل‌برداشت باشند؛ برای بخش‌های نامرتبط مقدار null بگذار.

این‌ها چند نماد مرجع (فقط برای الهام‌گیری، نه کپی مستقیم) هستند که ممکن است به متن خواب کاربر مرتبط باشند:
{{REFERENCE}}

خروجی را **فقط و فقط** به‌صورت یک JSON معتبر با دقیقاً این کلیدها بده، بدون هیچ توضیح اضافه، بدون backtick، بدون markdown:

{
  "summary": "خلاصه‌ی یک‌جمله‌ای و جذاب از کل خواب",
  "symbols": ["نماد۱", "نماد۲"],
  "fullInterpretation": "تعبیر یکپارچه و کامل خواب، چند جمله",
  "overallMessage": "پیام کلی خواب یا null",
  "emotional": "جنبه‌ی عاطفی یا null",
  "financial": "جنبه‌ی مالی یا null",
  "career": "جنبه‌ی کاری یا null",
  "family": "جنبه‌ی خانوادگی یا null",
  "warning": "نکته یا هشدار احتمالی یا null"
}`,
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { dreamText, source } = await req.json();

    if (!dreamText || String(dreamText).trim().length < 3) {
      return new Response(
        JSON.stringify({ error: "متن خواب خیلی کوتاه است" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const token = Deno.env.get("CLOUDFLARE_API_TOKEN");
    const accountId = Deno.env.get("CLOUDFLARE_ACCOUNT_ID");

    if (!token || !accountId) {
      return new Response(
        JSON.stringify({ error: "Cloudflare secrets missing" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const sourceKey = (source as string) || "traditional-fa";
    const promptTemplate = SOURCE_PROMPTS[sourceKey] ?? SOURCE_PROMPTS["traditional-fa"];
    const systemPrompt = promptTemplate.replace("{{REFERENCE}}", findReferenceContext(dreamText));

    const response = await fetch(
      `https://api.cloudflare.com/client/v4/accounts/${accountId}/ai/run/@cf/meta/llama-3.1-8b-instruct`,
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${token}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          messages: [
            { role: "system", content: systemPrompt },
            { role: "user", content: `خواب من: ${dreamText}` },
          ],
          temperature: 0.7,
        }),
      },
    );

    const data = await response.json();
    const rawReply = data?.result?.response ?? "";

    // مدل‌های کوچک گاهی متن اضافه قبل/بعد از JSON می‌گذارند؛ فقط بخش { ... } را استخراج می‌کنیم.
    let parsed: Record<string, unknown> | null = null;
    const jsonStart = rawReply.indexOf("{");
    const jsonEnd = rawReply.lastIndexOf("}");
    if (jsonStart !== -1 && jsonEnd !== -1 && jsonEnd > jsonStart) {
      try {
        parsed = JSON.parse(rawReply.slice(jsonStart, jsonEnd + 1));
      } catch (_e) {
        parsed = null;
      }
    }

    if (!parsed) {
      // اگر مدل JSON معتبر نداد، حداقل متن خام را به‌عنوان تعبیر کامل نشان می‌دهیم
      // تا کاربر با صفحه‌ی خالی یا خطا مواجه نشود.
      return new Response(
        JSON.stringify({
          summary: null,
          symbols: [],
          fullInterpretation: rawReply || "تعبیری برای این خواب پیدا نشد، دوباره تلاش کن.",
          overallMessage: null,
          emotional: null,
          financial: null,
          career: null,
          family: null,
          warning: null,
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    return new Response(JSON.stringify(parsed), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (e) {
    return new Response(
      JSON.stringify({ error: e.toString() }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
