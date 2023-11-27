import * as esbuild from "esbuild";

esbuild
  .build({
    entryPoints: ["./src/index.ts"],
    bundle: true,
    minify: true,
    outfile: "./dist/index.mjs",
    platform: "node",
    target: "node18",
    format: "esm",
    banner: {
      js: "import { createRequire } from 'module';const require = createRequire(import.meta.url);",
    },
  })
  .catch((err) => {
    process.stderr.write(err.stderr);
    process.exit(1);
  });
