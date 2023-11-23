import * as esbuild from "esbuild";

esbuild
  .build({
    entryPoints: ["./src/index.ts"],
    bundle: true,
    minify: true,
    outfile: "./dist/index.js",
    platform: "node",
    format: "esm",
  })
  .catch((err) => {
    process.stderr.write(err.stderr);
    process.exit(1);
  });
