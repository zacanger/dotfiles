#!/usr/bin/env node

// usage:
// ./tip-calculator.js price percentage
// percentage defaults to 20

const cost = Number(process.argv[2])
const perc = Number(process.argv[3] || 20)
const tip = cost * (perc / 100)
console.log(`
  Tip: ${tip.toFixed(2)}
  Total: ${(tip + cost).toFixed(2)}
`)
