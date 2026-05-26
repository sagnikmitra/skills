/** @type {import('next').NextConfig} */
const config = {
  reactStrictMode: true,
  // Allow reading content above the app root (the canonical registry at repo root).
  outputFileTracingRoot: new URL("../../", import.meta.url).pathname,
};
export default config;
