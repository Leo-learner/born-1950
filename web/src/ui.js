// 界面小工具：转义、格式化、图标

export const esc = s => String(s ?? '')
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
  .replace(/"/g, '&quot;').replace(/'/g, '&#39;');

/** 支持 **加粗** 和 *强调* */
export const inline = s => esc(s)
  .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
  .replace(/\*(.+?)\*/g, '<em>$1</em>');

export const joinDot = (parts, sep = ' · ') => parts.filter(Boolean).join(sep);

/** 全是英文字母、数字和标点（狗牌、报头、表格）的行用打字机体排——和 Mac 版 String.isLatin 一样 */
export const isLatin = s => !!s && Array.from(s).every(c => c.codePointAt(0) < 128 || c === '·' || c === '—' || c === '½');

export function duration(seconds) {
  const m = Math.floor(seconds / 60);
  return m >= 60 ? `${Math.floor(m / 60)} 小时 ${m % 60} 分` : `${m} 分钟`;
}

export const fmtDay = iso => new Date(iso).toLocaleDateString('zh-CN', { year: 'numeric', month: 'short', day: 'numeric' });
export const fmtStamp = iso => new Date(iso).toLocaleString('zh-CN', { dateStyle: 'short', timeStyle: 'short' });

/** 用真正的减号（−），数字对齐也好看些 */
export const signed = d => (d > 0 ? `+${d}` : `−${-d}`);

const svg = (body, { fill = false, size = 16 } = {}) =>
  `<svg class="ico" width="${size}" height="${size}" viewBox="0 0 24 24" aria-hidden="true" ${fill
    ? 'fill="currentColor" stroke="none"'
    : 'fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"'}>${body}</svg>`;

const box = '<path d="M12 2.8 20.5 7.2v9.6L12 21.2 3.5 16.8V7.2z"/><path d="M3.5 7.2 12 11.6l8.5-4.4"/><path d="M12 11.6v9.6"/><path d="m7.8 5 8.4 4.4"/>';
const envelope = '<rect x="3" y="5.5" width="18" height="13" rx="1.5"/><path d="m3.6 6.4 8.4 6.4 8.4-6.4"/>';

export const icons = {
  rewind: svg('<path d="M9 14 4 9l5-5"/><path d="M4 9h10.5a5.5 5.5 0 0 1 0 11H11"/>'),
  log: svg('<path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20V2H6.5A2.5 2.5 0 0 0 4 4.5z"/><path d="M4 19.5A2.5 2.5 0 0 0 6.5 22H20v-5"/><path d="M9 7h7"/>'),
  box: svg(box),
  boxLarge: svg(box, { size: 34 }),
  boxToast: svg(box, { size: 18 }),
  save: svg('<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><path d="m7 10 5 5 5-5"/><path d="M12 15V3"/>'),
  folder: svg('<path d="M3 6.5A1.5 1.5 0 0 1 4.5 5h4.2l2 2.2h8.8A1.5 1.5 0 0 1 21 8.7v9.8a1.5 1.5 0 0 1-1.5 1.5h-15A1.5 1.5 0 0 1 3 18.5z"/>'),
  album: svg('<rect x="3" y="4" width="18" height="16" rx="2"/><circle cx="12" cy="10.5" r="2.6"/><path d="M7.5 17.5c.8-2.3 2.5-3.5 4.5-3.5s3.7 1.2 4.5 3.5"/>'),
  sidebar: svg('<rect x="3" y="4" width="18" height="16" rx="2"/><path d="M15 4v16"/>'),
  house: svg('<path d="m3 10 9-7 9 7v10a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z"/>'),
  lock: svg('<path d="M7 11V7.5a5 5 0 0 1 10 0V11h.5A1.5 1.5 0 0 1 19 12.5v7a1.5 1.5 0 0 1-1.5 1.5h-11A1.5 1.5 0 0 1 5 19.5v-7A1.5 1.5 0 0 1 6.5 11zm2 0h6V7.5a3 3 0 0 0-6 0z"/>', { fill: true, size: 12 }),
  envelope: svg(envelope, { size: 11 }),
  envelopeOpen: svg('<path d="M3 10.5 12 4l9 6.5v8A1.5 1.5 0 0 1 19.5 20h-15A1.5 1.5 0 0 1 3 18.5z"/><path d="m3.5 10.8 8.5 6 8.5-6"/><path d="M7 8.3V5.8h10v2.5"/>', { size: 18 }),
  star: svg('<path d="m12 2.5 2.9 6 6.6.9-4.8 4.6 1.2 6.5L12 17.4l-5.9 3.1 1.2-6.5-4.8-4.6 6.6-.9z"/>', { fill: true, size: 10 }),
  chevronLeft: svg('<path d="m15 18-6-6 6-6"/>'),
  restart: svg('<path d="M3.5 12a8.5 8.5 0 1 0 2.5-6"/><path d="M3.5 3.5V8H8"/>'),
  close: svg('<path d="M6 6l12 12M18 6 6 18"/>'),
  cloud: svg('<path d="M7 18.5h10a4 4 0 0 0 .6-7.95A5.5 5.5 0 0 0 7 9.5a4.5 4.5 0 0 0 0 9z"/>', { size: 13 }),
};
