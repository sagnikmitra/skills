import { ImageResponse } from "next/og";

export const runtime = "edge";
export const alt = "Skills · sgnk — public catalog of agent skills";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export default async function OG() {
  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          background: "#1f1e1d",
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-between",
          padding: 80,
          color: "#f5f4ee",
          fontFamily: "system-ui, sans-serif",
        }}
      >
        <div style={{ display: "flex", alignItems: "center", gap: 16 }}>
          <div
            style={{
              width: 32,
              height: 32,
              borderRadius: 6,
              background: "linear-gradient(135deg, #e3916f, #d97757, #c8623f)",
            }}
          />
          <div style={{ fontSize: 24, fontWeight: 600, letterSpacing: -0.3 }}>
            sgnk · skills
          </div>
        </div>
        <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
          <div style={{ fontSize: 22, color: "#d97757", letterSpacing: 1, textTransform: "uppercase" }}>
            Skills registry
          </div>
          <div style={{ fontSize: 96, fontWeight: 600, letterSpacing: -3, lineHeight: 1.05 }}>
            Skills
          </div>
          <div style={{ fontSize: 28, color: "#c8c6bf", letterSpacing: -0.2, maxWidth: 900 }}>
            Public catalog of skills, workflows, and agent instructions —
            Claude · Codex · Antigravity.
          </div>
        </div>
        <div style={{ fontSize: 18, color: "#8a8780" }}>skills.sgnk.ai</div>
      </div>
    ),
    { ...size }
  );
}
