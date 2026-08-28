import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

// ============================================================================
// فال قهوه‌ی هوشمند — معماری دو مرحله‌ای
// ============================================================================
// چرا دو مرحله؟ از یه مدل تصویری خواستن که هم زیر لکه‌های مبهم شکل پیدا کنه
// هم از بین چند دسته انتخاب کنه هم تعبیر بسازه، هم کند بود هم کم‌دقت —
// چون همه‌ی این کارها با هم برای این نوع مدل سخته.
//
// راه‌حل: هر مدل فقط کاری که توش قویه رو انجام می‌ده:
//   مرحله‌ی ۱ (مدل تصویری): فقط *توصیف* می‌کنه چی تو عکس می‌بینه — کار طبیعی
//   یه مدل تصویری، نه دسته‌بندی انتزاعی.
//   مرحله‌ی ۲ (مدل متنی سریع، همون llama-3.1-8b که تو تعبیر خواب هم داریم):
//   اون توصیف رو می‌گیره، با ۲۰ نقش/تعبیر موجود پروژه مقایسه می‌کنه، و
//   تعبیر نهایی رو با لحن خودمون می‌سازه.

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const VISION_MODEL = "@cf/meta/llama-3.2-11b-vision-instruct";
const TEXT_MODEL = "@cf/meta/llama-3.1-8b-instruct";

// همون ۲۰ نقش و تعبیرِ دستچین‌شده‌ی موجود تو coffee_data.dart — این‌جا فقط
// به‌عنوان مرجع برای مدل متنی استفاده می‌شه، جایگزینشون نمی‌کنه.
const COFFEE_SYMBOLS: Record<string, string> = {
  "قلب": "نشانه‌ی عشقی صادق یا اتفاقی شیرین در حوزه‌ی احساسات که به‌زودی رخ می‌دهد.",
  "پرنده": "خبر خوش و پیامی مثبت در راه است؛ چیزی که مدتی منتظرش بودی.",
  "درخت": "نشانه‌ی رشد پایدار، ریشه‌دار بودن تصمیمات و ثباتی که در حال شکل‌گیری‌ست.",
  "ماهی": "نماد روزی و برکت مالی؛ فرصتی برای بهبود وضعیت اقتصادی نزدیک است.",
  "کلید": "راه‌حلی که دنبالش بودی پیدا می‌شود؛ دری که تصور می‌کردی بسته است، باز خواهد شد.",
  "ستاره": "شانس و موفقیت در راه است، به‌خصوص در موضوعی که اخیراً برایش تلاش کرده‌ای.",
  "دایره": "نشانه‌ی کامل شدن یک دوره یا بازگشت چیزی از گذشته به شکلی تازه.",
  "خط مواج": "سفر یا تغییری در پیش است؛ مسیر ممکن است پرپیچ‌وخم باشد اما به مقصد می‌رسی.",
  "صلیب": "نشانه‌ی یک تصمیم دشوار یا دوراهی‌ست که باید با دقت بیشتری به آن فکر کنی.",
  "تاج": "موفقیت، افتخار یا به‌رسمیت شناخته شدن تلاش‌هایت نزدیک است.",
  "چتر": "نیاز به محافظت از خود در برابر مشکلی موقتی؛ محتاط باش اما نگران نباش.",
  "لنگر": "ثبات و امنیتی که به دنبالش بودی، در حال رسیدن است؛ جایی برای تکیه کردن پیدا می‌کنی.",
  "ماه": "دوره‌ای احساسی و درون‌گرایانه در پیش داری؛ به شهودت اعتماد کن.",
  "خورشید": "نشانه‌ی شادی، موفقیت و روزهای روشن پیش‌رو؛ دوره‌ی خوبی در راه است.",
  "پروانه": "تحولی مثبت در شخصیت یا زندگی‌ات در حال شکل‌گیری‌ست؛ استقبال کن.",
  "مار": "هشداری برای مراقبت از یک فرد یا موقعیت که ممکن است صادق نباشد.",
  "کوه": "چالشی بزرگ اما قابل عبور در راه است؛ با پشتکار به آن غلبه می‌کنی.",
  "جاده": "مسیر روشنی پیش رویت باز می‌شود؛ زمان مناسبی برای تصمیم‌گیری قاطع است.",
  "خانه": "ثبات خانوادگی، خبری درباره‌ی محل زندگی یا آرامشی که به آن نیاز داشتی.",
  "حلقه": "نشانه‌ی تعهد، پیمانی تازه یا خبری مرتبط با ازدواج و روابط رسمی.",
};

async function agreeToLicense(accountId: string, token: string) {
  await fetch(
    `https://api.cloudflare.com/client/v4/accounts/${accountId}/ai/run/${VISION_MODEL}`,
    {
      method: "POST",
      headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
      body: JSON.stringify({ prompt: "agree" }),
    },
  );
}

async function describeImage(
  accountId: string,
  token: string,
  imageBytes: number[],
): Promise<string> {
  const prompt =
    "این عکس ته‌مانده‌ی تفاله‌ی یه فنجان قهوه‌ی برگردانده‌ست. فقط توصیف کن دقیقاً چه خط‌ها، لکه‌ها و شکل‌هایی از تفاله می‌بینی (مثلاً خط منحنی، نقطه‌های پراکنده، شکل گرد، انشعاب‌های شاخه‌مانند). تفسیر نکن، فقط توصیف تصویری بده، حداکثر ۴ جمله.";

  const call = async () =>
    await fetch(
      `https://api.cloudflare.com/client/v4/accounts/${accountId}/ai/run/${VISION_MODEL}`,
      {
        method: "POST",
        headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
        body: JSON.stringify({ prompt, image: imageBytes, max_tokens: 220 }),
      },
    );

  let res = await call();
  let data = await res.json();

  const errText = JSON.stringify(data?.errors ?? "");
  if (!res.ok || errText.toLowerCase().includes("agree") || errText.toLowerCase().includes("license")) {
    await agreeToLicense(accountId, token);
    res = await call();
    data = await res.json();
  }

  return data?.result?.response ?? "";
}

async function buildInterpretation(
  accountId: string,
  token: string,
  visualDescription: string,
): Promise<{ symbolName: string | null; interpretation: string }> {
  const referenceList = Object.entries(COFFEE_SYMBOLS)
    .map(([name, meaning]) => `- ${name}: ${meaning}`)
    .join("\n");

  const systemPrompt = `تو یه فال‌گیر باتجربه‌ی قهوه‌ی ایرانی برای اپ «کواکب» هستی.
یکی برات توصیف کرده تو فنجونش چه شکل‌هایی از تفاله می‌بینه. کارت اینه از بین نقش‌های سنتی زیر، نزدیک‌ترین‌شون رو به این توصیف پیدا کنی و یه تعبیر شخصی‌سازی‌شده بسازی (نه اینکه فقط متن آماده رو کپی کنی).

نقش‌های سنتی و معنای پایه‌شون:
${referenceList}

قوانین:
- اگه توصیف واقعاً به هیچ‌کدوم شبیه نبود یا خیلی مبهم بود، صادقانه بگو.
- از عبارت‌هایی مثل «می‌تواند نشانه‌ی ... باشد» استفاده کن، نه ادعای قطعی.
- خروجی فقط JSON با این دو کلید، بدون هیچ متن اضافه یا markdown:
{"symbolName": "دقیقاً یکی از ۲۰ اسم بالا یا null", "interpretation": "۲ تا ۳ جمله، بر پایه‌ی توصیف واقعی کاربر"}`;

  const res = await fetch(
    `https://api.cloudflare.com/client/v4/accounts/${accountId}/ai/run/${TEXT_MODEL}`,
    {
      method: "POST",
      headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
      body: JSON.stringify({
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: `توصیف فنجانم: ${visualDescription}` },
        ],
        max_tokens: 300,
      }),
    },
  );
  const data = await res.json();
  const rawReply: string = data?.result?.response ?? "";

  const jsonStart = rawReply.indexOf("{");
  const jsonEnd = rawReply.lastIndexOf("}");
  if (jsonStart !== -1 && jsonEnd !== -1 && jsonEnd > jsonStart) {
    try {
      const parsed = JSON.parse(rawReply.slice(jsonStart, jsonEnd + 1));
      const name = typeof parsed?.symbolName === "string" ? parsed.symbolName.trim() : null;
      const matched = name && COFFEE_SYMBOLS[name] ? name : null;
      return {
        symbolName: matched,
        interpretation: parsed?.interpretation || "نتونستم تعبیر روشنی پیدا کنم، دوباره امتحان کن.",
      };
    } catch (_e) {
      // پایین‌تر مدیریت می‌شه
    }
  }
  return { symbolName: null, interpretation: rawReply || "نتونستم فنجانت رو تحلیل کنم، دوباره امتحان کن." };
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { imageBase64 } = await req.json();
    if (!imageBase64 || String(imageBase64).length < 100) {
      return new Response(
        JSON.stringify({ error: "تصویر معتبر نیست" }),
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

    const binaryStr = atob(imageBase64);
    const imageBytes = new Array(binaryStr.length);
    for (let i = 0; i < binaryStr.length; i++) {
      imageBytes[i] = binaryStr.charCodeAt(i);
    }

    // مرحله‌ی ۱: مدل تصویری فقط توصیف می‌کنه
    const description = await describeImage(accountId, token, imageBytes);

    // مرحله‌ی ۲: مدل متنی سریع تعبیر نهایی رو می‌سازه
    const result = await buildInterpretation(accountId, token, description);

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (e) {
    return new Response(
      JSON.stringify({ error: e.toString() }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
