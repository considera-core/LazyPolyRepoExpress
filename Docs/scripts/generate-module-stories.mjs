// Scans Modules/**/*.bat and generates one Storybook MDX doc page per command.
//
// It reads the header comment block every Fn*.bat already carries:
//
//   :: FnGitBranch <OrgId> <SuiteId> <ProjectId>
//   :: leprechaun git branch <SuiteId> <ProjectId>      (optional CLI usage line)
//   :: -- Desc:
//   :: --   What the command does.
//   :: -- Input:
//   :: --   <OrgId>             The ID of the organization
//   :: -- Output:
//   :: --   void strout         The current Git branch
//
// Any `:: -- Name:` section is picked up, so adding `:: -- Example:` or
// `:: -- Notes:` to a script makes that section show up on its page with no
// change to this generator.

import { mkdirSync, readdirSync, readFileSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { dirname, join, relative, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(here, '..', '..');
const modulesRoot = join(repoRoot, 'Modules');
const outRoot = resolve(here, '..', 'src', 'stories', 'Modules');

/** Recursively collect every .bat under a directory. */
function findBatFiles(dir) {
  const found = [];
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) found.push(...findBatFiles(full));
    else if (entry.toLowerCase().endsWith('.bat')) found.push(full);
  }
  return found.sort();
}

/** Pull the leading `::` comment block off the top of a script. */
function headerLines(source) {
  const lines = [];
  for (const raw of source.split(/\r?\n/)) {
    const line = raw.trim();
    if (line === '') {
      if (lines.length === 0) continue; // leading blank lines
      break;
    }
    if (!line.startsWith('::')) break;
    const text = line.replace(/^::\s?/, '').trimEnd();
    if (/^=+$/.test(text.trim())) continue; // `:: =====` decoration
    lines.push(text);
  }
  return lines;
}

/**
 * Parse a header block into { signature, usage[], sections: [{ name, rows, text }] }.
 * A row is `<Term>  Description` (two or more spaces); anything else is free text.
 */
function parseHeader(lines) {
  const result = { signature: '', usage: [], sections: [] };
  let current = null;

  for (const line of lines) {
    if (!result.signature) {
      result.signature = line.trim();
      continue;
    }

    const section = line.match(/^--\s*([A-Za-z][A-Za-z0-9 _-]*):\s*$/);
    if (section) {
      current = { name: section[1].trim(), rows: [], text: [] };
      result.sections.push(current);
      continue;
    }

    if (line.startsWith('--')) {
      const body = line.replace(/^--\s?/, '').trim();
      if (body === '') continue;
      if (!current) {
        current = { name: 'Description', rows: [], text: [] };
        result.sections.push(current);
      }
      const row = body.match(/^(.+?)\s{2,}(.+)$/);
      if (row) current.rows.push({ term: row[1], description: row[2].trim() });
      else current.text.push(body);
      continue;
    }

    // A bare comment line under the signature: a second usage form.
    result.usage.push(line.trim());
  }

  return result;
}

/**
 * Map function name -> `leprechaun <module> <action>` by reading the
 * `Input_Module` / `Input_Actions` pair every Fn<Module>Dispatch.bat declares.
 */
function buildCliMap(files) {
  const map = new Map();
  for (const file of files) {
    if (!/Dispatch\.bat$/i.test(file)) continue;
    const source = readFileSync(file, 'utf8');
    const module = source.match(/SET\s+"Input_Module=([^"]+)"/i);
    const actions = source.match(/SET\s+"Input_Actions=([^"]*)"/i);
    const pascal = source.match(/SET\s+"Input_Pascal=([^"]+)"/i);
    if (!module || !actions || !pascal) continue;
    for (const pair of actions[1].trim().split(/\s+/).filter(Boolean)) {
      const [action, suffix] = pair.split(':');
      if (!action || !suffix) continue;
      map.set(`Fn${pascal[1]}${suffix}`.toLowerCase(), `leprechaun ${module[1]} ${action}`);
    }
  }
  return map;
}

/** MDX renders bare `<Foo>` and `{x}` as JSX, so neutralize them. */
function escapeMdx(text) {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/\{/g, '&#123;')
    .replace(/\}/g, '&#125;');
}

const escapeCell = (text) => escapeMdx(text).replace(/\|/g, '\|');

function renderSection(section) {
  const out = [`## ${escapeMdx(section.name)}`, ''];
  if (section.text.length) out.push(escapeMdx(section.text.join(' ')), '');
  if (section.rows.length) {
    out.push('| Name | Description |', '| --- | --- |');
    for (const row of section.rows) {
      out.push(`| \`${row.term.replace(/\|/g, '\|')}\` | ${escapeCell(row.description)} |`);
    }
    out.push('');
  }
  return out.join('\n');
}

function renderPage({ title, name, relPath, header, cli, source }) {
  const parts = [
    `import { Meta } from '@storybook/addon-docs/blocks';`,
    '',
    `<Meta title="${title}" />`,
    '',
    `# ${name}`,
    '',
    `\`${relPath.split(sep).join('/')}\``,
    '',
  ];

  const usage = [header.signature, ...header.usage].filter(Boolean);
  if (usage.length || cli) {
    parts.push('## Usage', '', '```bat');
    if (cli) parts.push(cli);
    parts.push(...usage);
    parts.push('```', '');
  }

  for (const section of header.sections) parts.push(renderSection(section));

  if (!header.sections.length) {
    parts.push('> This script has no `:: -- Desc: / Input: / Output:` header block yet.', '');
  }

  parts.push('## Source', '', '```bat', source.replace(/\r?\n$/, ''), '```', '');
  return parts.join('\n');
}

// ---------------------------------------------------------------------------

const files = findBatFiles(modulesRoot);
const cliMap = buildCliMap(files);

rmSync(outRoot, { recursive: true, force: true });

let written = 0;
for (const file of files) {
  const rel = relative(modulesRoot, file); // e.g. Internal/Git/FnGitBranch.bat
  const segments = rel.split(sep);
  const scope = segments[0]; // Internal | External
  const trail = segments.slice(1); // [Git, FnGitBranch.bat] or [Etc, Cache, Fn....bat]
  if (trail.length < 2) continue; // a .bat sitting loose at the scope root

  const name = trail[trail.length - 1].replace(/\.bat$/i, '');
  const groups = trail.slice(0, -1);
  const title = ['Modules', ...groups, name].join('/');

  const source = readFileSync(file, 'utf8');
  const header = parseHeader(headerLines(source));
  const page = renderPage({
    title,
    name,
    relPath: join('Modules', rel),
    header,
    cli: cliMap.get(name.toLowerCase()),
    source,
  });

  const outFile = join(outRoot, scope, ...groups, `${name}.mdx`);
  mkdirSync(dirname(outFile), { recursive: true });
  writeFileSync(outFile, page, 'utf8');
  written += 1;
}

console.log(`Generated ${written} module pages into ${relative(process.cwd(), outRoot)}`);
