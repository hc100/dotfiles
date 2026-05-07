#!/usr/bin/env node

import { appendFileSync, readFileSync } from "node:fs";

const minAgeDays = Number(process.env.MIN_RELEASE_AGE_DAYS || "7");
const now = new Date();

function read(path) {
  return readFileSync(path, "utf8");
}

function nixValue(text, key) {
  const match = text.match(new RegExp(`${key}\\s*=\\s*"([^"]+)"`));
  if (!match) {
    throw new Error(`Could not find ${key}`);
  }
  return match[1];
}

function ageDays(date) {
  return (now.getTime() - date.getTime()) / 86_400_000;
}

async function fetchJson(url, headers = {}) {
  const response = await fetch(url, { headers });
  if (!response.ok) {
    throw new Error(`${url}: HTTP ${response.status}`);
  }
  return response.json();
}

async function checkNpmPackage({ name, nixFile }) {
  const current = nixValue(read(nixFile), "version");
  const metadata = await fetchJson(`https://registry.npmjs.org/${name}`);
  const latest = metadata["dist-tags"]?.latest;
  const publishedAt = metadata.time?.[latest] ? new Date(metadata.time[latest]) : null;

  if (!latest || !publishedAt) {
    throw new Error(`${name}: missing latest version or publish time`);
  }

  return {
    name,
    source: "npm",
    current,
    latest,
    publishedAt,
    oldEnough: ageDays(publishedAt) >= minAgeDays,
    updateAvailable: latest !== current,
  };
}

async function checkGitHubHead({ name, nixFile, owner, repo, branch }) {
  const current = nixValue(read(nixFile), "rev");
  const headers = {
    Accept: "application/vnd.github+json",
    "X-GitHub-Api-Version": "2022-11-28",
  };

  const githubToken = process.env.GITHUB_TOKEN || process.env.GH_TOKEN;
  if (githubToken) {
    headers.Authorization = `Bearer ${githubToken}`;
  }

  const commit = await fetchJson(
    `https://api.github.com/repos/${owner}/${repo}/commits/${branch}`,
    headers,
  );
  const latest = commit.sha;
  const publishedAt = new Date(commit.commit?.committer?.date || commit.commit?.author?.date);

  return {
    name,
    source: "github",
    current,
    latest,
    publishedAt,
    oldEnough: ageDays(publishedAt) >= minAgeDays,
    updateAvailable: latest !== current,
  };
}

function renderResult(result) {
  const age = Math.floor(ageDays(result.publishedAt));
  const status = result.updateAvailable
    ? result.oldEnough
      ? "update available"
      : "new release is too recent"
    : "up to date";

  return [
    `### ${result.name}`,
    "",
    `- Source: ${result.source}`,
    `- Current: \`${result.current}\``,
    `- Latest: \`${result.latest}\``,
    `- Published: ${result.publishedAt.toISOString()} (${age} days ago)`,
    `- Status: ${status}`,
    "",
  ].join("\n");
}

async function main() {
  const results = [
    await checkNpmPackage({
      name: "dev-browser",
      nixFile: "packages/dev-browser.nix",
    }),
    await checkNpmPackage({
      name: "speca-cli",
      nixFile: "packages/speca-cli.nix",
    }),
    await checkGitHubHead({
      name: "awsp",
      nixFile: "packages/awsp.nix",
      owner: "johnnyopao",
      repo: "awsp",
      branch: "master",
    }),
  ];

  const summary = [
    "# Pinned package update check",
    "",
    `Minimum release age: ${minAgeDays} days`,
    "",
    ...results.map(renderResult),
  ].join("\n");

  console.log(summary);

  if (process.env.GITHUB_STEP_SUMMARY) {
    appendFileSync(process.env.GITHUB_STEP_SUMMARY, `${summary}\n`);
  }

  if (process.env.GITHUB_OUTPUT) {
    const actionable = results.some((result) => result.updateAvailable && result.oldEnough);
    appendFileSync(process.env.GITHUB_OUTPUT, `updates_found=${actionable}\n`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
