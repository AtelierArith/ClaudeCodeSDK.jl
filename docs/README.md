# Documentation for ClaudeCodeSDK.jl

This directory contains the documentation source and build system for ClaudeCodeSDK.jl using Documenter.jl.

## Building Documentation Locally

To build the documentation on your local machine:

```bash
# From the project root directory
julia --project=docs/ -e "using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()"
julia --project=docs docs/make.jl
```

The generated HTML documentation will be available in the `docs/build/` directory. Open `docs/build/index.html` in your web browser to view it.

## Documentation Structure

- `src/` - Documentation source files (Markdown)
  - `index.md` - Home page with overview and quick start
  - `getting-started.md` - Detailed getting started guide
  - `api.md` - Complete API reference with docstrings
  - `examples.md` - Comprehensive examples and usage patterns
  - `architecture.md` - In-depth architecture documentation
  - `errors.md` - Error handling guide
- `make.jl` - Documenter.jl build configuration
- `Project.toml` - Documentation environment dependencies
- `build/` - Generated HTML documentation (created when building)

## Automatic Deployment

The documentation is automatically built and deployed to GitHub Pages when changes are pushed to the main branch, using the GitHub Actions workflow in `.github/workflows/documentation.yml`.

## Adding New Pages

To add a new documentation page:

1. Create a new `.md` file in the `src/` directory
2. Add the page to the `pages` array in `make.jl`
3. Rebuild the documentation

## Docstring Format

The API documentation uses Julia docstrings. Example format:

```julia
"""
    function_name(arg1::Type, arg2::Type; keyword=default)

Brief description of the function.

# Arguments
- `arg1::Type`: Description of arg1
- `arg2::Type`: Description of arg2
- `keyword=default`: Description of keyword argument

# Returns
- `ReturnType`: Description of what is returned

# Examples
```julia
result = function_name("example", 42)
```
"""
function function_name(arg1, arg2; keyword=nothing)
    # implementation
end
```

For more information about Documenter.jl, see: https://documenter.juliadocs.org/