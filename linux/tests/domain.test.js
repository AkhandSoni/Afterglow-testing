import test from "node:test";
import assert from "node:assert/strict";
import {
  newLibrary,
  readLibrary,
  recordingKey,
  positionAt,
  resolveLine,
  appearance,
  excerptText,
  escape,
} from "../src/domain.js";
const track = { title: "सितारे", artist: "A:B", album: "C", duration: 120.9 };
test("recording identity counts UTF-8 bytes and avoids separator collisions", () => {
  assert.ok(recordingKey(track).startsWith("18:"));
  assert.notEqual(
    recordingKey({ ...track, title: "A:B", artist: "C" }),
    recordingKey({ ...track, title: "A", artist: "B:C" }),
  );
});
test("monotonic interpolation respects pause, rate, duration and backward seeks", () => {
  const s = {
    position: 5,
    received: 1000,
    playing: true,
    rate: 2,
    duration: 20,
  };
  assert.equal(positionAt(s, 3000), 9);
  assert.equal(positionAt({ ...s, playing: false }, 3000), 5);
  assert.equal(positionAt(s, 100000), 20);
  assert.equal(positionAt({ ...s, position: 1, received: 3000 }, 3000), 1);
});
test("line lookup preserves intros, empty interludes, word gaps and explicit ends", () => {
  const lines = [
    {
      time: 2,
      text: "Light returns",
      end: 6,
      words: [
        { text: "Light", time: 2, end: 3 },
        { text: "returns", time: 4, end: 5 },
      ],
    },
    { time: 8, text: "", words: [] },
    { time: 10, text: "Again", words: [] },
  ];
  assert.equal(resolveLine(lines, 1).index, -1);
  assert.equal(resolveLine(lines, 2).active, 0);
  assert.equal(resolveLine(lines, 3.5).active, -1);
  assert.equal(resolveLine(lines, 4.1).active, 1);
  assert.equal(resolveLine(lines, 6).index, -1);
  assert.equal(resolveLine(lines, 9).index, -1);
  assert.equal(resolveLine(lines, 10, false, 12).active, -1);
  assert.equal(resolveLine(lines, 10, true, 12).active, 0);
});
test("collection colors override scenes with explicit source and automatic creation order", () => {
  const lib = newLibrary(),
    key = recordingKey(track);
  lib.scenes[key] = { tint: "#112233", albumColor: false };
  lib.collections[0].color = "#ff0000";
  lib.collections[0].songs.push({ key, track });
  lib.collections[1].color = "#00ff00";
  lib.collections[1].songs.push({ key, track });
  assert.equal(appearance(lib, key, "#0000ff").color, "#ff0000");
  lib.colorSource[key] = "favorites";
  assert.equal(appearance(lib, key, "#0000ff").color, "#00ff00");
  lib.collections[1].songs = [];
  assert.equal(appearance(lib, key, "#0000ff").color, "#ff0000");
});
test("library roundtrip and invalid nested data fail without mutating the input", () => {
  const lib = newLibrary();
  assert.deepEqual(readLibrary(JSON.parse(JSON.stringify(lib))), lib);
  for (const bad of [
    { version: 2 },
    { collections: [{ id: "a", name: "b" }] },
    { settings: { tint: "url(secret)" } },
    { settings: { fontSize: NaN } },
    { excerpts: [{ text: "bad" }] },
    { imports: { x: { lines: [{ time: -1, text: "bad", words: [] }] } } },
  ]) {
    const before = JSON.stringify(bad);
    assert.throws(() => readLibrary(bad));
    assert.equal(JSON.stringify(bad), before);
  }
});
test("excerpt limits count Unicode characters and escape executable metadata", () => {
  const lines = Array.from({ length: 7 }, () => ({ text: "✨" }));
  assert.equal(excerptText(lines, new Set([0, 1])), "✨\n✨");
  assert.throws(() => excerptText(lines, new Set([0, 1, 2, 3, 4, 5, 6])));
  assert.throws(() => excerptText([{ text: "a".repeat(281) }], new Set([0])));
  assert.equal(escape('<script>"&'), "&lt;script&gt;&quot;&amp;");
});
