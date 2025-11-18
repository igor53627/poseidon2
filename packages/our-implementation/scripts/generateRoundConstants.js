#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const CONFIGS = [
  {
    field: 'goldilocks',
    prime: '0xFFFFFFFF00000001',
    t: 12,
    roundsF: 8,
    roundsP: 26,
    label: 'poseidon2_goldilocks_t12'
  }
];

class GrainLFSR {
  constructor(seedBuffer) {
    const seed = crypto
      .createHash('sha256')
      .update(seedBuffer)
      .digest();
    this.state = BigInt('0x' + seed.toString('hex'));
    if (this.state === 0n) {
      this.state = 1n;
    }
    this.mask = (1n << 256n) - 1n;
  }

  nextBit() {
    const bit0 = this.state & 1n;
    const bit2 = (this.state >> 2n) & 1n;
    const bit5 = (this.state >> 5n) & 1n;
    const bit10 = (this.state >> 10n) & 1n;
    const bit255 = (this.state >> 255n) & 1n;
    const newBit = bit0 ^ bit2 ^ bit5 ^ bit10 ^ bit255;
    this.state = ((this.state >> 1n) | (newBit << 255n)) & this.mask;
    return Number(bit0);
  }

  nextWord(width = 64) {
    let word = 0n;
    for (let i = 0n; i < BigInt(width); i++) {
      const bit = BigInt(this.nextBit());
      word |= bit << i;
    }
    return word;
  }

  nextFieldElement(prime) {
    const sample = this.nextWord(64);
    return sample % prime;
  }
}

function formatHex(value) {
  return '0x' + value.toString(16).padStart(16, '0');
}

function generateConstants(config) {
  const { field, prime, t, roundsF, roundsP, label } = config;
  const primeBigInt = BigInt(prime);
  const lfsr = new GrainLFSR(Buffer.from(`Poseidon2|${field}|t=${t}|p=${prime}`, 'utf8'));
  const totalRounds = roundsF + roundsP;
  const roundConstants = [];

  for (let r = 0; r < totalRounds; r++) {
    const row = [];
    for (let i = 0; i < t; i++) {
      const rc = lfsr.nextFieldElement(primeBigInt);
      row.push(formatHex(rc));
    }
    roundConstants.push(row);
  }

  return {
    field,
    prime,
    t,
    roundsF,
    roundsP,
    totalRounds,
    label,
    roundConstants
  };
}

function main() {
  const outDir = path.join(__dirname, 'artifacts');
  if (!fs.existsSync(outDir)) {
    fs.mkdirSync(outDir, { recursive: true });
  }

  for (const config of CONFIGS) {
    const data = generateConstants(config);
    const outPath = path.join(outDir, `${config.label}.json`);
    fs.writeFileSync(outPath, JSON.stringify(data, null, 2));
    console.log(`Generated constants for ${config.label} -> ${outPath}`);
  }
}

if (require.main === module) {
  main();
}
