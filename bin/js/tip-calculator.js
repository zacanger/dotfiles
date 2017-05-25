#!/usr/bin/env node
// usage:
// ./tip-calculator.js price percentage
// percentage defaults to 20

let cost = process.argv[2]
let percentage = process.argv[3] || 20
cost = Number(cost)
percentage = Number(percentage)
const tip = cost * (percentage / 100)
console.log(`
  Tip: ${tip.toFixed(2)}
  Total: ${(tip + cost).toFixed(2)}
`)
