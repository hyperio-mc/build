export const anthropicBrandGuidelines = `Anthropic brand guide:
- Main colors: Dark #141413, Light #faf9f5, Mid Gray #b0aea5, Light Gray #e8e6dc.
- Accent colors: Orange #d97757, Blue #6a9bcc, Green #788c5d.
- Typography: headings use Poppins with Arial fallback; body text uses Lora with Georgia fallback.
- Use brand colors with restrained confidence, preserving readability and hierarchy.`

export const anthropicFrontendDesignSkill = `Frontend design skill:
- Build distinctive, production-grade interfaces with a clear aesthetic point of view.
- Avoid generic AI aesthetics: predictable SaaS layouts, purple gradients, nested cards, default fonts, and cookie-cutter components.
- Make deliberate choices in typography, color, spacing, layout, motion, and visual details.
- Match implementation complexity to the aesthetic vision: maximal designs need rich details; minimal designs need precision.
- Use accessible, working code and preserve app functionality.`

export const scoutBrandStyles = `Scout Studio observed brand styles from https://studio.scoutos.com:
- Overall register: industrial-refined workshop aesthetic — precise, intentional, crafted.
- Font: GeistSans for UI chrome; Instrument Serif (italic) for headings and the Build wordmark. Use system sans fallback only after Geist.
- Base background: warm off-white #f5f5f3 (var --surface); raised surfaces pure white.
- Primary text: near-black #1a1a1f (var --ink); secondary text at ~65% opacity.
- Signature gradient: linear-gradient(110deg, #ff8acb, #73e3d4, #4f7dff) — used on the Build wordmark, textarea border, progress bar, selected-element panel border, and accent indicators.
- Primary controls: charcoal #2f3037 backgrounds with white text.
- Buttons: translateY(-1px) lift on hover with shadow intensification; spring easing for interactive feel.
- Message animations: slide-in from below with stagger (animation: msgSlideIn).
- Thinking indicator: left gradient accent bar (3px) + sweeping highlight animation.
- Selected element panel: gradient border using ::before pseudo-element at 40% opacity for a luminous card effect.
- Progress bar: gradient fill with shimmer overlay animation.
- Modal: slide-in from below with scale(0.97) spring ease.
- Noise texture: subtle SVG fractalNoise overlay at 1.8% opacity on the app shell for depth.
- Shadows: layered ring shadows (0 0 0 1px + y-shadow) for elevation; large 100px shadows for modals.
- App shell: 284px sidebar (down from 314px) for more preview breathing room.
- Chat messages: clamped to 8 lines (up from 5) before expansion.
- Avoid decorative gradients except the signature gradient and its soft variant; prefer precise spacing, crisp controls, and quiet contrast.`

export function designGuidancePrompt() {
  return `${anthropicFrontendDesignSkill}\n\n${anthropicBrandGuidelines}\n\n${scoutBrandStyles}`
}
