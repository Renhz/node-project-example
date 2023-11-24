import { describe, test, expect } from '@jest/globals';

describe('App Testing', () => {
  test('a==b', () => {
    const a = 'b';
    expect(a).toEqual('b');
  });
});
