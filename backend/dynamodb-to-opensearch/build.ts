import * as esbuild from "esbuild";

esbuild
  .build({
    entryPoints: ["./src/index.ts"],
    bundle: true,
    minify: true,
    outfile: "./dist/index.js",
    platform: "node",
    target: "node18",
  })
  .catch((err) => {
    process.stderr.write(err.stderr);
    process.exit(1);
  });
