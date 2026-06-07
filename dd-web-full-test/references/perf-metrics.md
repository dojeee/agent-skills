# Performance Metrics Reference

## Page Load (Core Web Vitals)

| Metric | What | Good (prod) | Acceptable (dev) | Collect |
|--------|------|-------------|------------------|---------|
| FCP | First Contentful Paint — first text/image painted | < 1.8s | < 5s | `performance.getEntriesByType("paint")` |
| LCP | Largest Contentful Paint — largest element rendered | < 2.5s | < 5s | `performance.getEntriesByType("largest-contentful-paint")` |
| DCL | DOMContentLoaded — HTML parsed | < 2s | < 5s | `navigation.domContentLoadedEventEnd` |
| TTI | Time to Interactive — page fully usable | < 3.8s | < 20s | `networkidle` wall-clock time |
| CLS | Cumulative Layout Shift — visual stability | < 0.1 | < 0.25 | `PerformanceObserver("layout-shift")` |

## Bundle

| Metric | Threshold | Tool |
|--------|-----------|------|
| Total JS size (prod) | < 300 KB (initial route) | `fs.readdirSync` + `fs.statSync` |
| Largest single chunk | < 500 KB | Sort chunks by size |
| Chunk count | < 50 | Count `.js` files in build output |
| Tree-shaking waste | No unused packages > 100KB | Manual review of top 15 chunks |

## API

| Metric | Good | Warning |
|--------|------|---------|
| Cold start latency | < 1s | > 3s |
| Warm latency (avg of 3) | < 300ms | > 1s |
| 99th percentile | < 2s | > 5s |

## Runtime

| Metric | Good | Warning | Collect |
|--------|------|---------|---------|
| JS Heap after usage | < 50 MB | > 100 MB | `performance.memory.usedJSHeapSize` |
| Long Tasks (>50ms) | 0 | > 5 per page load | `PerformanceObserver("longtask")` |
| SSE first-token delay | < 2s | > 10s | `Date.now()` on open vs first data |
| Streaming throughput | > 10 tokens/s | < 3 tokens/s | token count / duration |

## Cache

| Metric | Good | Tool |
|--------|------|------|
| 2nd visit transfer | ≈ 0 B | Compare `transferSize` visit1 vs visit2 |
| 3rd visit unchanged (304) | < 5 KB | Check `encodedBodySize` vs `transferSize` |

## Collection Code Template

```ts
// CLS
let cls = 0;
new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    if (!(entry as any).hadRecentInput) cls += (entry as any).value;
  }
}).observe({ type: "layout-shift", buffered: true });

// Long Tasks
const longTasks: number[] = [];
new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    longTasks.push(entry.duration);
  }
}).observe({ type: "longtask", buffered: true });

// Resource waterfall
const waterfall = performance.getEntriesByType("resource").map(r => ({
  name: r.name,
  duration: r.duration,
  transferSize: (r as PerformanceResourceTiming).transferSize,
  type: (r as PerformanceResourceTiming).initiatorType,
}));

// Cache check — second visit
const nav = performance.getEntriesByType("navigation")[0] as PerformanceNavigationTiming;
const cached = nav.transferSize === 0; // true = fully cached
```
