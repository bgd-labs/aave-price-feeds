import {formatUnits} from 'viem';
import {readFileSync, writeFileSync} from 'node:fs';

type CapoPrice = {
  referencePrice: number;
  sourcePrice: number;
  timestamp: number;
  dayToDayGrowth: number;
  smoothedGrowth: number;
};

export type CapoSnapshot = {
  decimals: number;
  reference: string;
  source: string;
  maxYearlyGrowthPercent: number;
  minSnapshotDelay: number;
  prices: Record<string, CapoPrice>;
};

type Price = {
  sourcePrice: string;
  referencePrice: string;
  diff: string;
  dayToDayGrowth: string;
  smoothedGrowth: string;
  date: string;
};

export async function generateCapoReport(snapshot: CapoSnapshot) {
  // map to dates and formatted values

  let prices: Price[] = [];

  let maxDayToDayGrowth = 0;
  let maxSmoothedGrowth = 0;

  for (const key in snapshot.prices) {
    const price = snapshot.prices[key];

    const sourcePrice = formatUnits(BigInt(price.sourcePrice), snapshot.decimals);
    const referencePrice = formatUnits(BigInt(price.referencePrice), snapshot.decimals);
    const dayToDayGrowth = (price.dayToDayGrowth / 100).toFixed(2);
    const smoothedGrowth = (price.smoothedGrowth / 100).toFixed(2);
    const diff = (
      (100 * (Number(sourcePrice) - Number(referencePrice))) /
      ((Number(sourcePrice) + Number(referencePrice)) / 2)
    ).toFixed(2);

    const formattedDate = formatTimestamp(price.timestamp);

    prices.push({
      sourcePrice,
      referencePrice,
      diff,
      dayToDayGrowth,
      smoothedGrowth,
      date: formattedDate,
    });

    maxDayToDayGrowth = Math.max(maxDayToDayGrowth, price.dayToDayGrowth);
    maxSmoothedGrowth = Math.max(maxSmoothedGrowth, price.smoothedGrowth);
  }

  prices = prices.slice(snapshot.minSnapshotDelay);

  // generate md report
  let content = '';
  content += `# Capo Report\n\n`;
  content += `| ${snapshot.source} | ${snapshot.reference} | Diff | Date | ${snapshot.minSnapshotDelay}-day growth in yearly % |\n`;
  content += `| --- | --- | --- | --- | --- |\n`;
  prices.forEach((price) => {
    content += `| ${price.sourcePrice} | ${price.referencePrice} | ${price.diff}% | ${price.date} | ${price.smoothedGrowth}% |\n`;
  });
  content += `\n\n`;
  content += `* ${snapshot.minSnapshotDelay}-day growth is calculated as an annualized percentage relative to the value of the rate ${snapshot.minSnapshotDelay} days prior. \n`;
  const maxYearlyGrowthPercent = (snapshot.maxYearlyGrowthPercent / 100).toFixed(2);
  const maxDayToDayGrowthPercent = (maxDayToDayGrowth / 100).toFixed(2);
  const maxSmoothedGrowthPercent = (maxSmoothedGrowth / 100).toFixed(2);

  content += `\n\n`;
  content += `| Max Yearly % | Max Day-to-day yearly % | Max ${snapshot.minSnapshotDelay}-day yearly % | \n`;
  content += `| --- | --- | --- |\n`;
  content += `| ${maxYearlyGrowthPercent}% | ${maxDayToDayGrowthPercent}% | ${maxSmoothedGrowthPercent}% | \n`;
  content += `\n\n`;

  content += `* Max day-to-day yearly % indicates the maximum growth between two emissions as an annualized percentage. \n`;

  return content;
}

function formatTimestamp(timestampInSec: number) {
  // Create a new Date object from the timestamp in seconds
  const date = new Date(timestampInSec * 1000);

  // Use the Intl.DateTimeFormat API to format the date
  return new Intl.DateTimeFormat('en-GB', {
    year: 'numeric',
    month: 'short',
    day: '2-digit',
    timeZone: 'GMT',
  }).format(date);
}

function parseArgs(args: string[]) {
  let inputPath = '';
  let outputPath = '';

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if ((arg === '-i' || arg === '--input') && i + 1 < args.length) {
      inputPath = args[++i];
      continue;
    }
    if ((arg === '-o' || arg === '--output') && i + 1 < args.length) {
      outputPath = args[++i];
      continue;
    }
  }

  return {inputPath, outputPath};
}

async function main() {
  const {inputPath, outputPath} = parseArgs(process.argv.slice(2));

  if (!inputPath || !outputPath) {
    throw new Error('Usage: capo-report.ts -i <input.json> -o <output.md>');
  }

  const snapshot = JSON.parse(readFileSync(inputPath, 'utf8')) as CapoSnapshot;
  const content = await generateCapoReport(snapshot);
  writeFileSync(outputPath, content);
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
