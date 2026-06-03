import gleam/list
import gleam/string

pub type ProjectFile {
  ProjectFile(path: String, content: String)
}

pub type FileTree {
  File(contents: String)
  Directory(children: List(#(String, FileTree)))
}

pub fn starter_files() -> List(ProjectFile) {
  [
    ProjectFile("package.json", package_json()),
    ProjectFile(
      "index.html",
      "<link rel=\"preconnect\" href=\"https://fonts.googleapis.com\"><link rel=\"preconnect\" href=\"https://fonts.gstatic.com\" crossorigin><link href=\"https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&display=swap\" rel=\"stylesheet\">\n<div id=\"root\"></div><script type=\"module\" src=\"/src/main.tsx\"></script>\n",
    ),
    ProjectFile("src/main.tsx", main_tsx()),
    ProjectFile("src/db.ts", db_ts()),
    ProjectFile("src/build-inspector.ts", build_inspector_ts()),
    ProjectFile("src/style.css", style_css()),
  ]
}

pub fn upsert_file(
  files: List(ProjectFile),
  path: String,
  content: String,
) -> List(ProjectFile) {
  let normalized = strip_leading_slashes(path)
  case list.any(files, fn(file) { file.path == normalized }) {
    True ->
      list.map(files, fn(file) {
        case file.path == normalized {
          True -> ProjectFile(normalized, content)
          False -> file
        }
      })
    False ->
      [ProjectFile(normalized, content), ..files]
      |> list.sort(by: fn(a, b) { string.compare(a.path, b.path) })
  }
}

pub fn files_to_tree(files: List(ProjectFile)) -> FileTree {
  Directory(files_to_nodes(files))
}

pub fn tree_get(tree: FileTree, path: String) -> Result(FileTree, Nil) {
  let parts = path |> string.split("/") |> list.filter(fn(part) { part != "" })
  do_tree_get(tree, parts)
}

fn do_tree_get(tree: FileTree, parts: List(String)) -> Result(FileTree, Nil) {
  case tree, parts {
    _, [] -> Ok(tree)
    Directory(children), [part, ..rest] ->
      case list.find(children, fn(child) { child.0 == part }) {
        Ok(child) -> do_tree_get(child.1, rest)
        Error(_) -> Error(Nil)
      }
    File(_), _ -> Error(Nil)
  }
}

fn files_to_nodes(files: List(ProjectFile)) -> List(#(String, FileTree)) {
  case files {
    [] -> []
    [file, ..rest] -> insert_file(files_to_nodes(rest), file)
  }
}

fn insert_file(
  nodes: List(#(String, FileTree)),
  file: ProjectFile,
) -> List(#(String, FileTree)) {
  let parts =
    file.path |> string.split("/") |> list.filter(fn(part) { part != "" })
  insert_parts(nodes, parts, file.content)
}

fn insert_parts(
  nodes: List(#(String, FileTree)),
  parts: List(String),
  content: String,
) -> List(#(String, FileTree)) {
  case parts {
    [] -> nodes
    [name] -> replace_node(nodes, name, File(content))
    [directory, ..rest] -> {
      let existing_children = case
        list.find(nodes, fn(node) { node.0 == directory })
      {
        Ok(#(_, Directory(children))) -> children
        _ -> []
      }
      replace_node(
        nodes,
        directory,
        Directory(insert_parts(existing_children, rest, content)),
      )
    }
  }
}

fn replace_node(
  nodes: List(#(String, FileTree)),
  name: String,
  tree: FileTree,
) -> List(#(String, FileTree)) {
  case list.any(nodes, fn(node) { node.0 == name }) {
    True ->
      list.map(nodes, fn(node) {
        case node.0 == name {
          True -> #(name, tree)
          False -> node
        }
      })
    False -> [#(name, tree), ..nodes]
  }
}

fn strip_leading_slashes(path: String) -> String {
  case string.starts_with(path, "/") {
    True ->
      strip_leading_slashes(string.slice(
        path,
        at_index: 1,
        length: string.length(path),
      ))
    False -> path
  }
}

fn package_json() -> String {
  "{\n  \"scripts\": {\n    \"dev\": \"vite --host 0.0.0.0\"\n  },\n  \"dependencies\": {\n    \"@vitejs/plugin-react\": \"latest\",\n    \"@electric-sql/pglite\": \"latest\",\n    \"vite\": \"latest\",\n    \"typescript\": \"latest\",\n    \"react\": \"latest\",\n    \"react-dom\": \"latest\"\n  },\n  \"devDependencies\": {},\n  \"type\": \"module\"\n}"
}

fn main_tsx() -> String {
  "import React, { useMemo, useState } from 'react'
import { createRoot } from 'react-dom/client'
import './build-inspector'
import './style.css'

type Answers = {
  idea: string
  audience: string
  problem: string
  features: string
  data: string
  style: string
  integrations: string
}

const questions: Array<{ key: keyof Answers; label: string; helper: string; placeholder: string }> = [
  {
    key: 'idea',
    label: 'What do you want to build?',
    helper: 'Name the app idea in one or two sentences.',
    placeholder: 'A booking app for local yoga instructors, a client portal for my agency...',
  },
  {
    key: 'audience',
    label: 'Who is it for?',
    helper: 'Describe the people who will use this app.',
    placeholder: 'Busy parents, freelance designers, restaurant managers...',
  },
  {
    key: 'problem',
    label: 'What should it help them do?',
    helper: 'Focus on the main job, frustration, or outcome.',
    placeholder: 'Track leads, schedule appointments, organize tasks, learn a skill...',
  },
  {
    key: 'features',
    label: 'What are the must-have features?',
    helper: 'List the screens, actions, or workflows you know you need.',
    placeholder: 'Dashboard, profiles, search, comments, status filters, admin view...',
  },
  {
    key: 'data',
    label: 'What information should it save?',
    helper: 'Mention important records, fields, or relationships.',
    placeholder: 'Customers with name/email/status, projects with tasks and due dates...',
  },
  {
    key: 'style',
    label: 'How should it look and feel?',
    helper: 'Pick a vibe, brand, or app you want it to resemble.',
    placeholder: 'Clean and modern like Linear, playful and colorful, premium SaaS...',
  },
  {
    key: 'integrations',
    label: 'Any extras or constraints?',
    helper: 'Auth, payments, uploads, charts, mobile-first, or anything to avoid.',
    placeholder: 'Login later, no payments yet, mobile-first, local browser database is fine...',
  },
]

const emptyAnswers: Answers = {
  idea: '',
  audience: '',
  problem: '',
  features: '',
  data: '',
  style: '',
  integrations: '',
}

function compact(value: string, fallback: string) {
  return value.trim() || fallback
}

function buildPlanSummary(answers: Answers) {
  const plan = {
    appIdea: compact(answers.idea, 'A useful web app based on the interview answers'),
    targetUsers: compact(answers.audience, 'People who need a simpler workflow'),
    primaryGoal: compact(answers.problem, 'Help users complete their core task quickly'),
    coreFeatures: compact(answers.features, 'A polished dashboard, clear navigation, create/edit flows, and helpful empty states'),
    dataToStore: compact(answers.data, 'Local app records with sensible fields and sample data'),
    visualDirection: compact(answers.style, 'Modern, friendly, responsive, and production-quality'),
    extrasAndConstraints: compact(answers.integrations, 'Keep it runnable in the browser with React, TypeScript, Vite, and PGlite when persistence is useful'),
  }

  const summary = `Build an app for: ${plan.appIdea}\\n\\nTarget users: ${plan.targetUsers}\\n\\nMain goal: ${plan.primaryGoal}\\n\\nMust-have features: ${plan.coreFeatures}\\n\\nData model / persistence: ${plan.dataToStore}\\n\\nVisual direction: ${plan.visualDirection}\\n\\nExtras / constraints: ${plan.extrasAndConstraints}`

  return { plan, summary }
}

function App() {
  const [step, setStep] = useState(0)
  const [answers, setAnswers] = useState<Answers>(emptyAnswers)
  const [sent, setSent] = useState(false)
  const current = questions[step]
  const progress = Math.round(((step + 1) / questions.length) * 100)
  const { plan, summary } = useMemo(() => buildPlanSummary(answers), [answers])
  const isReviewing = step >= questions.length

  function updateAnswer(value: string) {
    if (!current) return
    setAnswers(previous => ({ ...previous, [current.key]: value }))
  }

  function next() {
    setStep(value => Math.min(value + 1, questions.length))
  }

  function back() {
    setStep(value => Math.max(value - 1, 0))
  }

  function buildApp() {
    const message = { type: 'BUILD_APP_FROM_PLAN', plan, planSummary: summary }
    window.parent.postMessage(message, '*')
    setSent(true)
  }

  return <main className=\"shell\">
    <section className=\"intro\">
      <div>
        <p className=\"eyebrow\">Build starter</p>
        <h1>Welcome to Build.</h1>
        <p className=\"lede\">Let’s work through your idea and create an app for you today.</p>
      </div>
      <div className=\"hint\">You can also jump into chat anytime and tell the agent exactly what to change.</div>
    </section>

    <section className=\"panel\">
      <div className=\"progress\"><span style={{ width: `${isReviewing ? 100 : progress}%` }} /></div>
      {!isReviewing ? <>
        <p className=\"step\">Question {step + 1} of {questions.length}</p>
        <h2>{current.label}</h2>
        <p className=\"helper\">{current.helper}</p>
        <textarea
          autoFocus
          value={answers[current.key]}
          onChange={event => updateAnswer(event.target.value)}
          placeholder={current.placeholder}
        />
        <div className=\"actions\">
          <button className=\"secondary\" onClick={back} disabled={step === 0}>Back</button>
          <button onClick={next}>{step === questions.length - 1 ? 'Review app plan' : 'Next question'}</button>
        </div>
      </> : <>
        <p className=\"step\">Ready to build</p>
        <h2>Here’s the app plan</h2>
        <div className=\"summary\">
          <p><strong>App:</strong> {plan.appIdea}</p>
          <p><strong>Users:</strong> {plan.targetUsers}</p>
          <p><strong>Goal:</strong> {plan.primaryGoal}</p>
          <p><strong>Features:</strong> {plan.coreFeatures}</p>
          <p><strong>Data:</strong> {plan.dataToStore}</p>
          <p><strong>Style:</strong> {plan.visualDirection}</p>
          <p><strong>Extras:</strong> {plan.extrasAndConstraints}</p>
        </div>
        <div className=\"actions\">
          <button className=\"secondary\" onClick={back}>Edit answers</button>
          <button onClick={buildApp}>{sent ? 'Plan sent to Build' : 'Build this app'}</button>
        </div>
        <p className=\"footnote\">This button sends the summarized plan to the model along with the current code so it can replace this interview with your new app.</p>
      </>}
    </section>
  </main>
}

createRoot(document.getElementById('root')!).render(<App />)
"
}

fn db_ts() -> String {
  "import { PGlite } from '@electric-sql/pglite'

export const db = new PGlite('idb://preview-app')
"
}

fn build_inspector_ts() -> String {
  "const STYLE_ID = 'build-inspector-style'
let enabled = false
let hovered: Element | null = null

const style = document.createElement('style')
style.id = STYLE_ID
style.textContent = '[data-build-inspector-hover] { outline: 2px solid #6d8dff !important; outline-offset: 3px !important; cursor: crosshair !important; }'

function ensureStyle() {
  if (!document.getElementById(STYLE_ID)) document.head.appendChild(style)
}

function computedStylesFor(element: Element) {
  const styles = getComputedStyle(element)
  return {
    color: styles.color,
    backgroundColor: styles.backgroundColor,
    fontFamily: styles.fontFamily,
    fontSize: styles.fontSize,
    fontWeight: styles.fontWeight,
    display: styles.display,
    padding: styles.padding,
    margin: styles.margin,
    borderRadius: styles.borderRadius,
  }
}

function clearHover() {
  hovered?.removeAttribute('data-build-inspector-hover')
  hovered = null
}

function emitInspectorStatus(type: string) {
  window.parent.postMessage({ type }, '*')
}

emitInspectorStatus('BUILD_INSPECTOR_READY')

function enable() {
  enabled = true
  ensureStyle()
  emitInspectorStatus('BUILD_INSPECTOR_ENABLED')
}

function disable() {
  enabled = false
  clearHover()
  emitInspectorStatus('BUILD_INSPECTOR_DISABLED')
}

window.addEventListener('message', event => {
  if (event.data?.type === 'BUILD_INSPECTOR_ENABLE') enable()
  if (event.data?.type === 'BUILD_INSPECTOR_DISABLE') disable()
})

document.addEventListener('mouseover', event => {
  if (!enabled || !(event.target instanceof Element)) return
  clearHover()
  hovered = event.target
  hovered.setAttribute('data-build-inspector-hover', 'true')
}, true)

document.addEventListener('click', event => {
  if (!enabled || !(event.target instanceof Element)) return
  event.preventDefault()
  event.stopPropagation()
  const element = event.target
  emitInspectorStatus('BUILD_INSPECTOR_CLICK_SEEN')
  const rect = element.getBoundingClientRect()
  window.parent.postMessage({
    type: 'BUILD_ELEMENT_SELECTED',
    element: {
      tagName: element.tagName,
      id: element.id,
      classes: Array.from(element.classList),
      textContent: (element.textContent || '').trim().slice(0, 1000),
      outerHTML: element.outerHTML.slice(0, 4000),
      boundingRect: { x: rect.x, y: rect.y, width: rect.width, height: rect.height },
      computedStyles: computedStylesFor(element),
    },
  }, '*')
  disable()
}, true)
"
}

fn style_css() -> String {
  "@import url('https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&display=swap');\n\n:root {\n  --font-display: 'Instrument Serif', Georgia, 'Times New Roman', serif;\n  --font-ui: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;\n  --ink: #172033;\n  --ink-muted: #53627c;\n  --gradient: linear-gradient(110deg, #ff8acb, #73e3d4, #4f7dff);\n  --gradient-soft: linear-gradient(135deg, color(srgb 1 0.54 0.8 / .15), color(srgb 0.45 0.89 0.83 / .12), color(srgb 0.31 0.49 1 / .1));\n  --ease-out: cubic-bezier(.16, 1, .3, 1);\n  --ease-spring: cubic-bezier(.34, 1.56, .64, 1);\n\n  color: var(--ink);\n  background: radial-gradient(circle at top left, #eaf0ff 0, transparent 34rem), #f6f8fc;\n  font-family: var(--font-ui);\n}\nbody { margin: 0; }\nbutton, textarea { font: inherit; }\n.shell { max-width: 1040px; margin: 0 auto; padding: 56px 24px; }\n.intro {\n  display: grid;\n  grid-template-columns: minmax(0, 1fr) 280px;\n  gap: 24px;\n  align-items: end;\n  margin-bottom: 24px;\n}\n.eyebrow {\n  background: var(--gradient);\n  -webkit-background-clip: text;\n  -webkit-text-fill-color: transparent;\n  background-clip: text;\n  font-family: var(--font-ui);\n  font-size: .78rem;\n  font-weight: 800;\n  letter-spacing: .12em;\n  text-transform: uppercase;\n  margin: 0 0 12px;\n}\nh1 {\n  font-family: var(--font-display);\n  font-size: clamp(3rem, 9vw, 6.5rem);\n  line-height: .88;\n  letter-spacing: -.03em;\n  margin: 0;\n  color: var(--ink);\n}\nh2 {\n  font-family: var(--font-display);\n  color: #121a2b;\n  font-size: clamp(2rem, 4vw, 3.25rem);\n  line-height: 1;\n  letter-spacing: -.02em;\n  margin: 0;\n}\n.lede { color: var(--ink-muted); font-size: clamp(1.1rem, 2vw, 1.45rem); line-height: 1.45; max-width: 680px; margin: 22px 0 0; }\n.hint { color: var(--ink-muted); background: rgba(255,255,255,.72); border: 1px solid #e0e7f5; border-radius: 22px; padding: 18px; box-shadow: 0 20px 60px rgba(29,53,87,.08); }\n.panel {\n  background: rgba(255,255,255,.9);\n  border: 1px solid transparent;\n  border-radius: 32px;\n  padding: 30px;\n  position: relative;\n  background-clip: padding-box;\n  box-shadow: 0 28px 90px rgba(29,53,87,.12);\n  animation: panelIn .4s cubic-bezier(.16, 1, .3, 1) both;\n}\n.panel::before {\n  content: '';\n  position: absolute;\n  inset: -1px;\n  border-radius: inherit;\n  background: linear-gradient(110deg, color(srgb 1 .54 .8 / .2), color(srgb .45 .89 .83 / .15), color(srgb .31 .49 1 / .2));\n  z-index: -1;\n}\n@keyframes panelIn {\n  from { opacity: 0; transform: translateY(8px); }\n  to { opacity: 1; transform: translateY(0); }\n}\n.progress { height: 10px; background: #edf2fb; border-radius: 999px; overflow: hidden; margin-bottom: 28px; }\n.progress span {\n  display: block;\n  height: 100%;\n  background: var(--gradient);\n  border-radius: inherit;\n  transition: width .4s cubic-bezier(.16, 1, .3, 1);\n  position: relative;\n  overflow: hidden;\n}\n.progress span::after {\n  content: '';\n  position: absolute;\n  inset: 0;\n  background: linear-gradient(90deg, transparent, rgba(255,255,255,.4), transparent);\n  animation: shimmer 2s ease-in-out infinite;\n}\n@keyframes shimmer {\n  0% { transform: translateX(-100%); }\n  100% { transform: translateX(100%); }\n}\n.step { color: #4169ff; font-size: .8rem; font-weight: 800; letter-spacing: .1em; text-transform: uppercase; margin: 0 0 10px; }\n.helper { color: var(--ink-muted); font-size: 1.05rem; line-height: 1.55; margin: 14px 0 18px; }\ntextarea {\n  box-sizing: border-box;\n  width: 100%;\n  min-height: 180px;\n  resize: vertical;\n  color: var(--ink);\n  background: #fbfcff;\n  border: 1px solid transparent;\n  border-radius: 22px;\n  padding: 18px;\n  outline: none;\n  background: linear-gradient(#fbfcff, #fbfcff) padding-box, var(--gradient) border-box;\n  box-shadow: 0 8px 32px rgba(29,53,87,.08);\n  transition: box-shadow .25s ease;\n}\ntextarea:focus { box-shadow: 0 0 0 4px rgba(65,105,255,.12), 0 12px 40px rgba(29,53,87,.12); }\n.actions { display: flex; justify-content: space-between; gap: 12px; margin-top: 22px; }\nbutton {\n  border: 0;\n  border-radius: 16px;\n  background: #305cff;\n  color: white;\n  font-weight: 800;\n  padding: 14px 20px;\n  cursor: pointer;\n  box-shadow: 0 12px 30px rgba(48,92,255,.28);\n  transition: transform .15s cubic-bezier(.34, 1.56, .64, 1), box-shadow .15s ease;\n}\nbutton:hover:not(:disabled) { transform: translateY(-2px); box-shadow: 0 16px 40px rgba(48,92,255,.35); }\nbutton:active:not(:disabled) { transform: translateY(0); }\nbutton:disabled { opacity: .45; cursor: not-allowed; transform: none; }\nbutton.secondary { color: #30405f; background: #eef3fb; box-shadow: 0 2px 8px rgba(29,53,87,.06); }\nbutton.secondary:hover:not(:disabled) { background: #e4ecfa; box-shadow: 0 4px 16px rgba(29,53,87,.1); }\n.summary { display: grid; gap: 12px; margin-top: 22px; }\n.summary p {\n  margin: 0;\n  padding: 16px;\n  border: 1px solid #e1e8f4;\n  border-radius: 18px;\n  background: #fbfcff;\n  color: #4c5c78;\n  line-height: 1.45;\n  transition: border-color .15s ease, box-shadow .15s ease;\n}\n.summary p:hover {\n  border-color: color(srgb .31 .49 1 / .3);\n  box-shadow: 0 4px 16px rgba(65,105,255,.08);\n}\n.summary strong { color: #172033; }\n.footnote { color: var(--ink-muted); font-size: .92rem; line-height: 1.5; margin: 16px 0 0; }\n@media (max-width: 760px) {\n  .shell { padding: 32px 16px; }\n  .intro { grid-template-columns: 1fr; }\n  .panel { padding: 22px; border-radius: 24px; }\n  .actions { flex-direction: column-reverse; }\n  button { width: 100%; }\n}"
}
