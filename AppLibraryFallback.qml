import QtQuick
import QtQml
import Quickshell
import qs.Commons

// Compatibility facade used when Omarchy does not grant the app-library facade.
//
// Omarchy grants the application-library facade from the manifest the panel
// Instantiator delivers, where the nested `kinds` array is no longer a JS array
// (`Array.isArray(kinds) === false`), so `manifestHasKind(manifest, "menu")` is
// false and a third-party menu plugin is handed a scoped plugin shell whose
// `appLibrary` is null. The launcher's app grid then renders empty while the
// rest of the UI works, which reads as a launcher bug rather than a host one.
// Tracking: omacom/omarchy#10661 (canonical fix: omacom/omarchy#10785).
//
// This exposes the same narrow interface Menu.qml expects, backed by
// Quickshell's DesktopEntries. Menu.qml prefers `shell.appLibrary` whenever the
// host provides it, so this file becomes inert once the host is fixed. It lives
// in a separate file so future upstream edits to Menu.qml cannot conflict with
// the fallback implementation.
QtObject {
  id: library

  signal appsChanged()

  function entryName(entry) {
    return entry ? String(entry.name || entry.id || "") : ""
  }

  function entrySubtext(entry) {
    if (!entry) return ""
    var parts = []
    if (entry.genericName) parts.push(String(entry.genericName))
    if (entry.comment) parts.push(String(entry.comment))
    return parts.join(" · ")
  }

  function sortedEntries(query) {
    var values = (typeof DesktopEntries !== "undefined" && DesktopEntries
      && DesktopEntries.applications) ? DesktopEntries.applications.values : []
    var text = String(query || "").trim().toLowerCase()
    var rows = []
    for (var i = 0; i < values.length; i++) {
      var entry = values[i]
      if (!entry || entry.noDisplay) continue
      var name = entryName(entry)
      if (!name) continue
      if (text) {
        var haystack = [name, entry.id, entry.genericName, entry.comment]
          .join(" ").toLowerCase()
        if (haystack.indexOf(text) < 0) continue
      }
      rows.push({ entry: entry, score: 0, name: name.toLowerCase() })
    }
    rows.sort(function(a, b) {
      return a.name < b.name ? -1 : (a.name > b.name ? 1 : 0)
    })
    return rows
  }

  function iconSource(icon) {
    var value = String(icon || "")
    if (!value) return Quickshell.iconPath("application-x-executable", true)
    if (value.indexOf("file://") === 0 || value.indexOf("image://") === 0)
      return value
    if (value.charAt(0) === "/") return Util.fileUrl(value)
    var themed = Quickshell.iconPath(value, true)
    return themed.length > 0
      ? themed : Quickshell.iconPath("application-x-executable", true)
  }

  function refreshIcons() {}

  function launch(desktopId, name) {
    var id = String(desktopId || "")
    if (!id) return
    // Same launch path Omarchy's own AppLibrary uses.
    Util.execDetached("uwsm-app -- gtk-launch "
      + Util.shellQuote(id.replace(/\.desktop$/i, "") + ".desktop"))
  }
}
