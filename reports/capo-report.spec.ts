import fs from 'node:fs';
import path from 'node:path';
import {describe, expect, it} from 'vitest';
import {generateCapoReport} from './capo-report';
/**
 * While javascript supports bigint, JSON.parse doesn't
 * Therefore this file contains utilities to parse JSON containing bigint
 */
import JSONbig from 'json-bigint';

describe('capo report', () => {
  it('should generate a well formatted capo report', {timeout: 30000}, async () => {
    const mockPath = '/reports/mocks/capo.json';
    const snapshotStr = fs.readFileSync(path.join(process.cwd(), mockPath), 'utf8');
    const snapshot = JSON.parse(JSON.stringify(JSONbig({storeAsString: true}).parse(snapshotStr)));
    const content = await generateCapoReport(snapshot);
    expect(content).toMatchSnapshot();
  });
});
