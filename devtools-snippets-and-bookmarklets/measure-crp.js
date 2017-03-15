const measureCRP = () => {
  const t = window.performance.timing
  const interactive = t.domInteractive - t.domLoading
  const dcl = t.domContentLoadedEventStart - t.domLoading
  const complete = t.domComplete - t.domLoading
  console.log({ interactive, dcl, complete })
}
document.body.onload = measureCRP()
