# Open edX Full Backup — edx.echiphub.in

Complete backup of Open edX (Tutor Indigo 20.0.4) with omnix theme, NIELIT branding, and all customizations.

**Live URL:** https://edx.echiphub.in  
**MFE URL:** https://apps.edx.echiphub.in

---

## What's Included

| Directory | Contents |
|-----------|----------|
| themes/omnix/ | Full omnix theme (templates, static CSS, JS, images, logos) |
| themes/staticfiles-omnix/ | Collected static files (hashed versions) |
| tutor-env/ | Tutor config, Docker Compose, Caddy, build files |
| mfe-dist-backups/ | All 10 MFE index.html files (with Montserrat + responsive CSS + dropdown JS) |
| databases/ | MySQL + MongoDB dumps (if included) |

### Key Files

- **themes/omnix/lms/templates/body-extra.html** — All inline CSS overrides (loads on every LMS page without collectstatic)
- **themes/omnix/lms/static/css/lms-main-v1.css** — Main LMS stylesheet with global Montserrat override appended
- **mfe-dist-backups/*/index.html** — MFE pages with Montserrat font, responsive header, mobile dropdown nav

---

## Prerequisites

- Ubuntu 20.04+ (or any Linux with Docker)
- Docker + Docker Compose
- Tutor 20.0.4 (Teak release)
- 8GB RAM, 30GB disk minimum

---

## Quick Restore

### Step 1: Clone This Repo

    git clone https://github.com/fse05-edtech/openedx-final-backup.git
    cd openedx-final-backup

### Step 2: Restore LMS Theme Overrides

    # Copy the template with all CSS overrides (Montserrat, teal/cream theme, footer, responsive)
    docker cp themes/omnix/lms/templates/body-extra.html tutor_local-lms-1:/openedx/themes/omnix/lms/templates/

    # Copy the main CSS with Montserrat appended
    docker cp themes/omnix/lms/static/css/lms-main-v1.css tutor_local-lms-1:/openedx/themes/omnix/lms/static/css/

    # Restart LMS (no collectstatic needed for template changes)
    docker restart tutor_local-lms-1 tutor_local-cms-1 tutor_local-lms-worker-1 tutor_local-cms-worker-1

### Step 3: Restore MFE Customizations

    # Copy all 10 MFE index.html files (Montserrat + responsive header + dropdown nav)
    for mfe in account authn authoring communications discussions gradebook learner-dashboard learning ora-grading profile; do
      docker cp mfe-dist-backups/$mfe/index.html tutor_local-mfe-1:/openedx/dist/$mfe/
    done

    # Restart MFE container
    docker restart tutor_local-mfe-1

### Step 4: Verify

- Hard refresh (`Ctrl+Shift+R`) on https://edx.echiphub.in
- Check home page: cream header/footer (#fff9ef)
- Check course page: teal header/footer (#1a5c5a)
- Check MFE (apps.edx.echiphub.in): Montserrat font, responsive mobile header
- Open hamburger menu on mobile: should show Discuss + Get Help links

---

## Customizations Applied

### LMS (via body-extra.html inline styles)
- **Montserrat font** globally on all pages (`*:not(.fa)`)
- **Home page:** cream #fff9ef header/footer with teal #94bab7 pill buttons
- **Non-home pages:** teal #1a5c5a header/footer with white text
- **Register button** matches Login/Courses style (teal filled)
- **Footer:** 3-column flex layout (brand | quick links | address)
- **Responsive:** hamburger menu on mobile, desktop nav buttons

### LMS (via lms-main-v1.css)
- Global Montserrat `@import` + `font-family` override appended at end
- FontAwesome and bootstrap-icons fonts preserved

### MFE (via index.html injection)
- **Montserrat font** (full range 100-900, italic) via Google Fonts `<link>` + `<style>` override
- **Responsive header CSS:** wraps on mobile, truncates course title, hides theme toggle
- **Dropdown JS:** injects Discuss + Get Help links into hamburger menu on mobile

---

## Taking a New Backup

    # body-extra.html (all CSS overrides)
    docker cp tutor_local-lms-1:/openedx/themes/omnix/lms/templates/body-extra.html themes/omnix/lms/templates/

    # lms-main-v1.css
    docker cp tutor_local-lms-1:/openedx/themes/omnix/lms/static/css/lms-main-v1.css themes/omnix/lms/static/css/

    # All MFE index.html files
    for mfe in account authn authoring communications discussions gradebook learner-dashboard learning ora-grading profile; do
      docker cp tutor_local-mfe-1:/openedx/dist/$mfe/index.html mfe-dist-backups/$mfe/
    done

    git add -A && git commit -m "Backup update" && git push

---

## Important Warnings

- **body-extra.html** changes take effect on container restart — NO collectstatic needed
- **lms-main-v1.css** changes need `collectstatic` to regenerate hashed filenames
- **MFE index.html** changes take effect on container restart
- **NEVER** use `bash !important` in commands — use `set +H` first, then `python3 << 'PYEOF'` heredoc
- Container restarts take ~30 seconds; hard refresh browser after

---

*Last updated: April 2026*
