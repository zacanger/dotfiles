const setCookie = (key, val, expiresAt, domain) => {
  const kv = `${key}=${val}`
  const exp = expiresAt ? `expires=${expiresAt.toUTCString()}` : ''
  const dom = domain ? `domain=${domain}` : ''
  const path = 'path=/'
  const c = [kv, exp, dom, path].filter(Boolean).join('; ')
  document.cookie = c
}
