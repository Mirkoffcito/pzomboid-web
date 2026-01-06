const DEFAULT_LOCALE = "es-AR" // or undefined to use browser locale

export const LocalUpdatedAt = {
  mounted() { this.render(); this.startTicker(); },
  updated() { this.render(); },
  destroyed() { this.stopTicker(); },

  render() {
    const iso = this.el.dataset.iso
    if (!iso) return

    const d = new Date(iso)
    if (isNaN(d.getTime())) return

    const locale = this.el.dataset.locale || DEFAULT_LOCALE

    const abs = new Intl.DateTimeFormat(locale, {
      dateStyle: "medium",
      timeStyle: "short",
    }).format(d)

    const rel = this.relativeFromNow(d, locale)

    this.el.textContent = rel
    this.el.title = abs
  },

  startTicker() {
    this._timer = setInterval(() => this.render(), 30_000)
  },

  stopTicker() {
    if (this._timer) clearInterval(this._timer)
    this._timer = null
  },

  relativeFromNow(date, locale) {
    const seconds = Math.round((date.getTime() - Date.now()) / 1000)
    const rtf = new Intl.RelativeTimeFormat(locale, { numeric: "auto" })

    const ranges = [
      { unit: "day", secs: 86400 },
      { unit: "hour", secs: 3600 },
      { unit: "minute", secs: 60 },
      { unit: "second", secs: 1 },
    ]

    for (const r of ranges) {
      if (Math.abs(seconds) >= r.secs || r.unit === "second") {
        return rtf.format(Math.round(seconds / r.secs), r.unit)
      }
    }
  },
}
