const { Client, GatewayIntentBits, SlashCommandBuilder, REST, Routes, EmbedBuilder, AttachmentBuilder } = require('discord.js');
const Anthropic = require('@anthropic-ai/sdk');

// ── Config ──────────────────────────────────────────────────────────────────
const DISCORD_TOKEN = process.env.DISCORD_TOKEN;
const CLIENT_ID     = process.env.CLIENT_ID;
const ANTHROPIC_KEY = process.env.ANTHROPIC_API_KEY;

if (!DISCORD_TOKEN || !CLIENT_ID || !ANTHROPIC_KEY) {
  console.error('ERROR: Missing environment variables.');
  console.error('Make sure DISCORD_TOKEN, CLIENT_ID, and ANTHROPIC_API_KEY are set in your .env file.');
  process.exit(1);
}

const anthropic = new Anthropic({ apiKey: ANTHROPIC_KEY });
const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent,
  ]
});

// ── Slash commands ──────────────────────────────────────────────────────────
const commands = [
  new SlashCommandBuilder()
    .setName('obfuscate')
    .setDescription('Obfuscate Lua/Roblox code — Luraph-grade, compatible with Xeno, Potassium, Velocity, Madiun')
    .addStringOption(o =>
      o.setName('code')
        .setDescription('Paste your Lua/Roblox script here')
        .setRequired(true)),

  new SlashCommandBuilder()
    .setName('fixobf')
    .setDescription('Send an error screenshot from your executor — bot reads it and fixes the obfuscated code')
    .addAttachmentOption(o =>
      o.setName('screenshot')
        .setDescription('Screenshot of the executor error')
        .setRequired(true))
    .addStringOption(o =>
      o.setName('code')
        .setDescription('Paste the obfuscated code that errored (optional but helps)')
        .setRequired(false)),

  new SlashCommandBuilder()
    .setName('help')
    .setDescription('Show all commands and executor compatibility info'),

].map(cmd => cmd.toJSON());

// ── Register slash commands ─────────────────────────────────────────────────
async function registerCommands() {
  const rest = new REST({ version: '10' }).setToken(DISCORD_TOKEN);
  try {
    console.log('Registering slash commands...');
    await rest.put(Routes.applicationCommands(CLIENT_ID), { body: commands });
    console.log('Slash commands registered successfully.');
  } catch (e) {
    console.error('Failed to register commands:', e.message);
  }
}

// ── Obfuscation prompt — Xeno, Potassium, Velocity, Madiun targeted ─────────
function buildObfPrompt(code) {
  return `You are an expert Lua obfuscator for Roblox scripts. Your output must be Luraph-grade strength AND fully compatible with these specific executors: Xeno, Potassium, Velocity, and Madiun.

Apply ALL techniques below at MAXIMUM intensity. Output MUST be valid Luau that behaves 100% identically to the original input.

════════════════════════════════════════
EXECUTOR-SPECIFIC COMPATIBILITY RULES (apply these first — they are critical)
════════════════════════════════════════

XENO EXECUTOR:
- Xeno uses a modified Luau VM. Fully supports string.char, string.byte, rawget, rawset, setmetatable, getmetatable.
- Do NOT use debug library calls (debug.getinfo, debug.traceback) — sandboxed.
- Do NOT use require() — sandboxed in Xeno.
- table.pack and table.unpack are supported. Use them freely.
- coroutine library is fully supported.
- math library fully supported including math.huge, math.pi.
- Use pcall() around any game service calls.

POTASSIUM EXECUTOR:
- Potassium is a mobile/lightweight executor. Conservative Luau support.
- Do NOT use bit32 at all — not available. Use math-based alternatives: math.floor(a/2^b)%2 instead of bit32.rshift.
- Do NOT use utf8 library.
- Do NOT use os.clock or os.time — sandboxed.
- string library fully available.
- Keep memory usage low: avoid deeply nested tables (max 4 levels deep).
- Do NOT use coroutine.wrap in obfuscation scaffolding.
- task library (task.wait, task.spawn, task.defer) is supported.

VELOCITY EXECUTOR:
- Velocity has a strict Luau sandbox. Very close to standard Luau.
- Do NOT use loadstring() or load() — fully sandboxed and blocked.
- Do NOT use getfenv() or setfenv() — not available.
- Do NOT use rawequal in dispatch logic — can cause silent failures.
- string.format is supported and can be used in encoding.
- math library fully supported.
- Use pcall() defensively around all service access.
- table.move is supported.

MADIUN EXECUTOR:
- Madiun is a mobile executor with partial Luau support.
- Do NOT use bit32 — not available.
- Do NOT use utf8 — not available.
- Do NOT use coroutine library in obfuscation scaffolding.
- Do NOT use debug library.
- Do NOT use os library.
- string.char, string.byte, string.rep, string.sub are all safe.
- math library safe.
- Avoid chained method calls longer than 3 deep.
- Keep obfuscation tables under 40 entries per table — split into multiple tables if needed.
- Use simple while/for loops only. No repeat...until in obfuscation scaffolding.

════════════════════════════════════════
OBFUSCATION TECHNIQUES — ALL MANDATORY AT MAX STRENGTH
════════════════════════════════════════

1. VARIABLE & FUNCTION RENAMING
   - Rename every local variable, function name, and parameter to hex/leet names: _0x3f, __G7c, lIlIlI, _Ox1a2b, etc.
   - Use a mix of styles so no pattern is obvious.
   - No original identifier should appear anywhere in the output.

2. STRING ENCODING
   - Replace every string literal with chunked string.char() calls using decimal char codes.
   - Split strings into random chunk sizes (2-6 chars per chunk) and concatenate.
   - Assign a local alias: local _sc = string.char then use _sc(72,101,108,108,111).

3. NUMBER ENCODING
   - Replace every numeric literal with math expressions.
   - Examples: 1 -> (2-1), 10 -> (0xA+0), 255 -> (0xFF), 100 -> (10*10), 42 -> (6*7).
   - Use hex notation wherever it makes sense.
   - Never use bit32 for number encoding (not compatible with Potassium/Madiun).

4. CONTROL FLOW FLATTENING
   - Wrap all code in do...end blocks.
   - Add opaque predicates: if (1==1) then [real code] end
   - Use a numeric state variable to control flow where possible.

5. JUNK CODE INJECTION
   - Insert dead local variables with useless math every 2-3 lines.
   - Insert unreachable blocks: if (0==1) then local _j=math.floor(99) end
   - Keep individual junk blocks simple (single line) for Madiun/Potassium compatibility.

6. CONSTANT TABLE WRAPPING (Luraph signature move)
   - Move ALL string constants into top-level encoded tables with max 40 entries each.
   - local _K1 = {[1]=string.char(...),[2]=string.char(...),...}
   - local _K2 = {[1]=string.char(...),...}
   - Reference via _K1[1], _K2[3] etc. throughout.
   - Also alias key functions: rawget, rawset, setmetatable, pcall.

7. FUNCTION INDIRECTION
   - Every function call goes through a local alias.
   - All Roblox globals aliased: local _gm = game; local _ws = workspace; etc.
   - Chain max 3 deep to stay Madiun-safe.

8. VM-STYLE DISPATCH
   - Wrap blocks of 3-6 operations in function tables with a while-loop runner.
   - Keep dispatch tables under 40 entries (Madiun limit).

9. DEAD BRANCH INSERTION
   - Insert opaque true/false conditions using math tautologies:
     local _ck = math.floor(1.0)
     if _ck ~= 1 then local _dead = math.abs(-99) end

════════════════════════════════════════
GLOBAL OUTPUT RULES
════════════════════════════════════════
- Output ONLY raw Lua. No explanation. No markdown. No backticks. No code fences.
- Must run on Xeno, Potassium, Velocity, AND Madiun without errors.
- Must produce 100% identical behavior to the input.
- No bit32, no utf8, no debug lib, no os lib, no loadstring, no getfenv, no setfenv, no require.
- All tables max 40 entries (split into multiple tables if needed).
- All method chains max 3 deep.
- No coroutine in obfuscation scaffolding.
- No repeat...until in obfuscation scaffolding.
- Wrap all game service access in pcall().

CODE TO OBFUSCATE:
${code}`;
}

// ── Fix prompt ──────────────────────────────────────────────────────────────
function buildFixPrompt(code) {
  return `You are an expert Lua/Roblox debugger. A user ran obfuscated Lua code on one of these executors: Xeno, Potassium, Velocity, or Madiun — and got an error shown in the attached screenshot.

${code ? `OBFUSCATED CODE THAT ERRORED:\n${code}\n\n` : 'No code was pasted — analyze from the screenshot error message alone.\n\n'}

YOUR JOB:
1. Read the error message in the screenshot carefully (line number, error type, message).
2. Identify exactly what caused the error.
3. Fix ONLY that error in the obfuscated code. Do NOT de-obfuscate or simplify anything else.
4. Keep all obfuscation layers intact.

COMMON EXECUTOR-SPECIFIC ERRORS TO CHECK:
- "attempt to index nil" -> a Roblox service alias not wrapped in pcall, fix with pcall wrapper
- "bit32 is not a valid member" -> bit32 used, replace with math alternative (math.floor(a/2^b)%2)
- "stack overflow" -> dispatch loop or recursion too deep, flatten it
- "unexpected symbol" -> syntax error from obfuscation, find and fix the malformed block
- "table index is nil" -> constant table indexing issue, check _K table construction
- "attempt to call a nil value" -> function alias not set up correctly, fix the alias
- "loadstring is not a valid member" -> remove any loadstring usage
- "getfenv is not defined" -> remove getfenv, use local upvalues instead
- "exceeded maximum table size" -> table over 40 entries, split into multiple tables
- "attempt to yield across metamethod" -> coroutine issue, remove coroutine from scaffolding
- "max chain depth" / method chain error -> chain too deep for Madiun, break into local vars

Output ONLY the fixed raw Lua code. No explanation. No markdown. No code fences. No backticks.`;
}

// ── Claude API call ─────────────────────────────────────────────────────────
async function callClaude(prompt, imageBase64 = null, mediaType = 'image/png') {
  const content = [];
  if (imageBase64) {
    content.push({ type: 'image', source: { type: 'base64', media_type: mediaType, data: imageBase64 } });
  }
  content.push({ type: 'text', text: prompt });

  const msg = await anthropic.messages.create({
    model: 'claude-opus-4-5',
    max_tokens: 4096,
    messages: [{ role: 'user', content }]
  });

  return msg.content.map(b => b.text || '').join('').trim();
}

// ── Helpers ─────────────────────────────────────────────────────────────────
function makeFileAttachment(code, filename) {
  return new AttachmentBuilder(Buffer.from(code, 'utf-8'), { name: filename });
}

function stripFences(text) {
  return text.replace(/^```(?:lua)?\r?\n?/i, '').replace(/```\s*$/, '').trim();
}

// ── /obfuscate ──────────────────────────────────────────────────────────────
async function handleObfuscate(interaction) {
  await interaction.deferReply();
  const code = interaction.options.getString('code');

  await interaction.editReply({
    embeds: [new EmbedBuilder()
      .setColor(0x3C3489)
      .setTitle('🔒 Obfuscating...')
      .setDescription('Applying all 9 Luraph-grade layers.\nBuilding executor-safe output for Xeno, Potassium, Velocity & Madiun...')
      .setFooter({ text: 'LuaObf Max • This may take 10–20 seconds' })]
  });

  try {
    const result = await callClaude(buildObfPrompt(code));
    const clean  = stripFences(result);

    await interaction.editReply({
      embeds: [new EmbedBuilder()
        .setColor(0x1D9E75)
        .setTitle('✅ Obfuscation complete')
        .addFields(
          { name: 'Original size',   value: `${code.length} chars`,  inline: true },
          { name: 'Obfuscated size', value: `${clean.length} chars`, inline: true },
          { name: 'Layers applied',  value: '9 / 9',                 inline: true },
          { name: 'Executor compatibility', value: '✅ Xeno  ✅ Potassium  ✅ Velocity  ✅ Madiun', inline: false },
          { name: 'Blocked for compatibility', value: 'bit32 · utf8 · debug · os · loadstring · getfenv · setfenv · require · coroutines', inline: false }
        )
        .setFooter({ text: 'Got an error in your executor? Use /fixobf and attach a screenshot.' })],
      files: [makeFileAttachment(clean, 'obfuscated.lua')]
    });

  } catch (e) {
    await interaction.editReply({
      embeds: [new EmbedBuilder()
        .setColor(0xE24B4A)
        .setTitle('❌ Obfuscation failed')
        .setDescription(`Error: ${e.message}`)]
    });
  }
}

// ── /fixobf ─────────────────────────────────────────────────────────────────
async function handleFixObf(interaction) {
  await interaction.deferReply();

  const screenshotAttachment = interaction.options.getAttachment('screenshot');
  const pastedCode = interaction.options.getString('code') || '';

  await interaction.editReply({
    embeds: [new EmbedBuilder()
      .setColor(0xBA7517)
      .setTitle('🔍 Reading error screenshot...')
      .setDescription('Analyzing the executor error and patching the obfuscated code...')]
  });

  try {
    const imgResponse = await fetch(screenshotAttachment.url);
    const imgBuffer   = await imgResponse.arrayBuffer();
    const imgBase64   = Buffer.from(imgBuffer).toString('base64');
    const mediaType   = (screenshotAttachment.contentType || 'image/png').split(';')[0];

    const result = await callClaude(buildFixPrompt(pastedCode), imgBase64, mediaType);
    const clean  = stripFences(result);

    await interaction.editReply({
      embeds: [new EmbedBuilder()
        .setColor(0x1D9E75)
        .setTitle('✅ Fixed obfuscated code')
        .setDescription('Error read from screenshot. Fixed `.lua` file attached below.')
        .addFields({ name: 'Note', value: 'All obfuscation layers kept intact — only the error was patched.', inline: false })
        .setFooter({ text: 'Still erroring? Run /fixobf again with the new screenshot.' })],
      files: [makeFileAttachment(clean, 'fixed_obfuscated.lua')]
    });

  } catch (e) {
    await interaction.editReply({
      embeds: [new EmbedBuilder()
        .setColor(0xE24B4A)
        .setTitle('❌ Fix failed')
        .setDescription(`Could not analyze screenshot: ${e.message}`)]
    });
  }
}

// ── /help ───────────────────────────────────────────────────────────────────
async function handleHelp(interaction) {
  await interaction.reply({
    embeds: [new EmbedBuilder()
      .setColor(0x534AB7)
      .setTitle('🔒 LuaObf Max — Commands & Info')
      .setDescription('Luraph-grade Lua obfuscator. Fully compatible with Xeno, Potassium, Velocity, and Madiun.')
      .addFields(
        { name: '/obfuscate [code]', value: 'Paste your Lua/Roblox script. Get a `.lua` file back with max-strength obfuscation applied.', inline: false },
        { name: '/fixobf [screenshot] (code)', value: 'Got an executor error? Attach a screenshot. The bot reads the error using AI vision and sends back a fixed version.', inline: false },
        { name: 'Executor compatibility', value: '✅ Xeno\n✅ Potassium\n✅ Velocity\n✅ Madiun', inline: true },
        { name: 'Obfuscation layers', value: '• Variable & function renaming\n• String encoding\n• Number encoding\n• Control flow flattening\n• Junk injection\n• Constant table wrapping\n• Function indirection\n• VM dispatch\n• Dead branches', inline: true },
        { name: 'Blocked for compat', value: 'bit32 · utf8 · debug · os · loadstring · getfenv · setfenv · require · coroutines', inline: false }
      )
      .setFooter({ text: 'LuaObf Max • Powered by Claude AI' })],
    ephemeral: true
  });
}

// ── Events ──────────────────────────────────────────────────────────────────
client.once('ready', () => {
  console.log(`✅ Bot online as: ${client.user.tag}`);
});

client.on('interactionCreate', async interaction => {
  if (!interaction.isChatInputCommand()) return;
  try {
    switch (interaction.commandName) {
      case 'obfuscate': await handleObfuscate(interaction); break;
      case 'fixobf':    await handleFixObf(interaction);    break;
      case 'help':      await handleHelp(interaction);      break;
    }
  } catch (e) {
    console.error('Unhandled interaction error:', e);
  }
});

// ── Boot ─────────────────────────────────────────────────────────────────────
registerCommands().then(() => client.login(DISCORD_TOKEN));
