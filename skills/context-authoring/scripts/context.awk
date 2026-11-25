BEGIN {
  nF = split("Id|Type|Status|Evidence|Source|Verification|Revisit when|See|Superseded by", F, "|")
  split("type|status|evidence|source|verification|revisit-when|see|superseded-by", O, "|")
  for (k = 2; k <= nF; k++) field[O[k - 1]] = F[k]
  h = "[0-9a-f]"
  UUID = h h h h h h h h "-" h h h h "-" h h h h "-" h h h h "-" h h h h h h h h h h h h
  d = "[0-9]"
  DATE = d d d d "-" d d "-" d d
  SEP = " — "
  req["Id"] = req["Status"] = req["Evidence"] = 1
  multi["Type"] = multi["See"] = 1
  re["Id"] = "^" UUID "$"
  re["Type"] = "^(decision|workaround|incident|constraint)$"
  re["Status"] = "^(active|superseded|open|needs-review)$"
  re["Evidence"] = "^(confirmed|inferred|unknown)$"
  re["Source"] = re["Revisit when"] = "[^ ]"
  re["Verification"] = "^(corroborated|uncorroborated|contradicted)" SEP "[^ ]"
  re["See"] = "^([a-z0-9-]+[.]md#[a-z0-9_-]+|https://[^ ]+)" SEP UUID SEP "as of " DATE "$"
  re["Superseded by"] = "^(" UUID "|https://[^ ]+" SEP UUID SEP "as of " DATE "|none" SEP "[^ ].*)$"
  cmd = ENVIRON["CMD"]
}

FNR == 1 {
  file[++nf] = FILENAME
  name[nf] = FILENAME
  sub(/.*\//, "", name[nf])
  theme[nf] = name[nf]
  sub(/[.]md$/, "", theme[nf])
  fidx[theme[nf]] = nf
  cur = 0
}
{ orig[nf] = orig[nf] $0 "\n" }
/^## / { efile[++ne] = nf; fe[nf, ++nfe[nf]] = ne; cur = ne }
cur { raw[cur, ++nl[cur]] = $0; next }
{ pre[nf, ++npre[nf]] = $0 }

END {
  for (e = 1; e <= ne; e++) parse(e)
  na = split(ENVIRON["ARGS"], A, "\n")
  if (na && A[na] == "") na--
  if (cmd == "themes") {
    for (f = 1; f <= nf; f++) print theme[f] (summary(f) == "" ? "" : SEP summary(f))
    exit
  }
  if (cmd == "entries") {
    if (!na) for (f = 1; f <= nf; f++) A[++na] = theme[f]
    for (i = 1; i <= na; i++) {
      f = need(A[i])
      print theme[f] ":"
      for (k = 1; k <= nfe[f]; k++) {
        e = fe[f, k]
        print substr(fv[e, "Id"], 1, 8) " " fv[e, "Status"] " " heading[e]
      }
    }
    exit
  }
  if (cmd == "show") {
    if (!na) die("show needs an Id")
    for (i = 1; i <= na; i++) printf "%s%s\n", (i > 1 ? "\n" : ""), text(resolve(A[i]))
    exit
  }
  nopt = split(ENVIRON["OPTS"], L, "\n")
  for (i = 1; i < nopt; i++) {
    o = substr(L[i], 1, index(L[i], " ") - 1)
    if (given[o] && o != "type" && o != "see") die("--" o " is given twice")
    ov[o, ++given[o]] = substr(L[i], index(L[i], " ") + 1)
  }
  if (cmd == "theme") dotheme(A[1])
  else if (cmd == "add") doadd(need(A[1]), A[2])
  else if (cmd == "set") doset(resolve(A[1]))
  else if (cmd == "move") domove(resolve(A[1]), need(A[2]))
  repair()
  for (f = 1; f <= nf; f++) {
    if (oldpath[f] != "") print oldpath[f] > (ENVIRON["RMLIST"])
    if (gone[f]) {
      print file[f] > (ENVIRON["RMLIST"])
      continue
    }
    out = render(f)
    if (out != orig[f]) {
      printf "%s", out > (file[f])
      close(file[f])
    }
  }
}

function die(m) {
  print "context.sh: " m | "cat 1>&2"
  close("cat 1>&2")
  exit 1
}

function parse(e,   i, f) {
  heading[e] = substr(raw[e, 1], 4)
  blank(e)
  for (i = 2; i <= nl[e] && raw[e, i] == ""; i++) ;
  for (hs[e] = i; i <= nl[e] && match(raw[e, i], /^[*][*][A-Za-z ]+:[*][*] /); i++) {
    f = substr(raw[e, i], 3, RLENGTH - 6)
    if (!(f in re)) bad[e] = f
    else fv[e, f] = fv[e, f] == "" ? substr(raw[e, i], RLENGTH + 1) : fv[e, f] "\n" substr(raw[e, i], RLENGTH + 1)
  }
  he[e] = i - 1
  for (; i <= nl[e] && raw[e, i] == ""; i++) ;
  bs[e] = i
  for (last[e] = nl[e]; last[e] > 1 && raw[e, last[e]] == ""; last[e]--) ;
  idx[fv[e, "Id"]] = e
}

function blank(e,   k) {
  bad[e] = ""
  for (k = 1; k <= nF; k++) fv[e, F[k]] = ""
}

function text(e,   out, i) {
  out = raw[e, 1]
  for (i = 2; i <= last[e]; i++) out = out "\n" raw[e, i]
  return out
}

function render(f,   out, i, n, k) {
  for (n = npre[f]; n > 0 && pre[f, n] == ""; n--) ;
  out = pre[f, 1]
  for (i = 2; i <= n; i++) out = out "\n" pre[f, i]
  for (k = 1; k <= nfe[f]; k++) out = out "\n\n" text(fe[f, k])
  return out "\n"
}

function summary(f,   i) {
  for (i = 2; i <= npre[f]; i++) if (pre[f, i] != "") return pre[f, i]
  return ""
}

function need(t) {
  if (!(t in fidx)) die("no theme " t)
  return fidx[t]
}

function resolve(p,   e, hit, n) {
  for (e = 1; e <= ne; e++) if (p != "" && index(fv[e, "Id"], p) == 1) { hit = e; n++ }
  if (n != 1) die(n ? p " matches " n " entries" : "no entry has an Id starting with " p)
  return hit
}

function anchor(s) {
  s = tolower(s)
  gsub(/[^a-z0-9 _-]/, "", s)
  gsub(/ /, "-", s)
  return s
}

function locator(e) {
  return name[efile[e]] "#" anchor(heading[e])
}

function first(v) {
  return index(v, " ") ? substr(v, 1, index(v, " ") - 1) : v
}

function rest(v) {
  return index(v, " ") ? substr(v, index(v, " ") + 1) : ""
}

function uuidof(v,   P) {
  return split(v, P, SEP) > 1 ? P[2] : P[1]
}

function kebab(t) {
  if (t !~ /^[a-z0-9]+(-[a-z0-9]+)*$/) die("a theme name is lowercase kebab-case: " t)
}

function dotheme(t,   f, i, n) {
  kebab(t)
  if (!(t in fidx)) {
    if (given["rename"]) die("no theme " t)
    if (ov["title", 1] == "" || ov["summary", 1] == "") die("a new theme needs --title and --summary")
    f = fidx[t] = ++nf
    file[f] = ENVIRON["DIR"] "/" t ".md"
    name[f] = t ".md"
    theme[f] = t
  }
  f = fidx[t]
  if (given["title"]) {
    if (ov["title", 1] !~ /[^ ]/) die("--title needs text")
    pre[f, 1] = "# " ov["title", 1]
    if (!npre[f]) npre[f] = 1
  }
  if (given["summary"]) {
    if (ov["summary", 1] !~ /[^ ]/) die("--summary needs text")
    for (i = 2; i <= npre[f] && pre[f, i] == ""; i++) ;
    if (i > npre[f]) {
      pre[f, 2] = ""
      npre[f] = i = 3
    }
    pre[f, i] = ov["summary", 1]
  }
  if (given["rename"]) {
    n = ov["rename", 1]
    kebab(n)
    if (n in fidx) die("theme " n " exists already")
    oldpath[f] = file[f]
    orig[f] = ""
    delete fidx[t]
    fidx[n] = f
    theme[f] = n
    name[f] = n ".md"
    file[f] = ENVIRON["DIR"] "/" n ".md"
  }
}

function doadd(f, h,   e) {
  e = ++ne
  efile[e] = f
  fe[f, ++nfe[f]] = e
  blank(e)
  heading[e] = h
  if (ENVIRON["NEWID"] !~ re["Id"] || (ENVIRON["NEWID"] in idx)) die("cannot make an Id: neither uuidgen nor /proc/sys/kernel/random/uuid works")
  fv[e, "Id"] = ENVIRON["NEWID"]
  write(e, 1)
  print fv[e, "Id"]
}

function doset(e) {
  if (bad[e] != "") die("the entry has the unknown field " bad[e])
  if (given["heading"]) heading[e] = ov["heading", 1]
  write(e, ENVIRON["BODY"] != "")
}

function domove(e, f,   s, k, n) {
  s = efile[e]
  if (f == s) die("the entry is in " theme[f] " already")
  for (k = 1; k <= nfe[s]; k++) if (fe[s, k] != e) fe[s, ++n] = fe[s, k]
  nfe[s] = n
  efile[e] = f
  fe[f, ++nfe[f]] = e
  unique(e)
  if (!n) gone[s] = 1
}

function write(e, newbody,   old, o, f, i, v, list, out, k, n, V, B, b0, b1) {
  old = fv[e, "See"] "\n" fv[e, "Superseded by"]
  for (o in field) if (given[o]) {
    f = field[o]
    list = ""
    for (i = 1; i <= given[o]; i++) {
      v = ov[o, i]
      if (v == "") continue
      if (f == "Verification") v = first(v) SEP rest(v)
      else if (f == "Superseded by" && first(v) == "none") v = "none" SEP rest(v)
      else if (f == "See" || f == "Superseded by") v = cite(e, v, o, old)
      list = list == "" ? v : list "\n" v
    }
    fv[e, f] = list
  }
  out = "## " heading[e] "\n"
  for (k = 1; k <= nF; k++) {
    n = fv[e, F[k]] == "" ? 0 : split(fv[e, F[k]], V, "\n")
    for (i = 1; i <= n; i++) out = out "\n**" F[k] ":** " V[i]
  }
  out = out "\n"
  if (newbody) {
    for (n = 0; (getline v < ENVIRON["BODY"]) > 0;) B[++n] = v
    for (b0 = 1; b0 <= n && B[b0] ~ /^[ \t]*$/; b0++) ;
    for (b1 = n; b1 >= b0 && B[b1] ~ /^[ \t]*$/; b1--) ;
    for (i = b0; i <= b1; i++) out = out "\n" B[i]
  } else for (i = bs[e]; i <= last[e]; i++) out = out "\n" raw[e, i]
  nl[e] = split(out, V, "\n")
  for (i = 1; i <= nl[e]; i++) raw[e, i] = V[i]
  parse(e)
  unique(e)
  validate(e)
}

function cite(e, v, o, old,   t, u, P) {
  if (v ~ /^https:/) {
    u = rest(v)
    v = first(v)
    if (v ~ /[.]git$|\/$|#/ || u !~ re["Id"]) die("--" o " takes <url> <id> with a repository URL and a full Id")
  } else {
    t = resolve(v)
    if (t == e) die("an entry cannot cite itself")
    u = fv[t, "Id"]
    if (o == "superseded-by") return u
    v = locator(t)
  }
  return v SEP u SEP "as of " (match(old, SEP u SEP "as of " DATE) ? substr(old, RSTART + RLENGTH - 10, 10) : ENVIRON["TODAY"])
}

function unique(e,   f, k, a) {
  if (heading[e] !~ /[^ ]/ || heading[e] ~ /^#/) die("a heading needs text")
  f = efile[e]
  a = anchor(heading[e])
  for (k = 1; k <= nfe[f]; k++) if (fe[f, k] != e && anchor(heading[fe[f, k]]) == a) die(name[f] " has the heading " heading[fe[f, k]] " already")
}

function validate(e,   k, f, n, V, i, u, seen) {
  for (k = 1; k <= nF; k++) {
    f = F[k]
    n = fv[e, f] == "" ? 0 : split(fv[e, f], V, "\n")
    if (req[f] && !n) die(f " is required")
    if (n > 1 && !(f in multi)) die(f " takes one value")
    for (i = 1; i <= n; i++) {
      if (V[i] !~ re[f]) die(f " cannot be: " V[i])
      u = f == "Type" ? V[i] : uuidof(V[i])
      if ((f, u) in seen) die(f " repeats " u)
      seen[f, u] = 1
      if ((f == "See" || f == "Superseded by") && V[i] !~ /^(https|none)/ && !(u in idx)) die(f " cites " u ", which no entry has")
    }
  }
  if ((fv[e, "Status"] == "superseded") != (fv[e, "Superseded by"] != "")) die("Superseded by goes with the status superseded, and only with it")
  if (bs[e] > last[e]) die("the body is empty")
  for (i = bs[e]; i <= last[e]; i++) if (raw[e, i] ~ /^##? /) die("the body cannot hold a # or ## heading")
}

function repair(   e, i, n, P, loc) {
  for (e = 1; e <= ne; e++) for (i = hs[e]; i <= he[e]; i++) {
    if (raw[e, i] !~ /^[*][*]See:[*][*] / || split(substr(raw[e, i], 10), P, SEP) != 3 || P[1] ~ /^https:/ || !(P[2] in idx)) continue
    loc = locator(idx[P[2]])
    if (loc != P[1]) raw[e, i] = "**See:** " loc SEP P[2] SEP P[3]
  }
}
