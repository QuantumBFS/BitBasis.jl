JL = julia --project

default: init

init:
	$(JL) -e 'using Pkg; Pkg.instantiate(); Pkg.precompile(); Pkg.activate("docs"); Pkg.instantiate(); Pkg.precompile()'

update:
	$(JL) -e 'using Pkg; Pkg.update(); Pkg.precompile(); Pkg.activate("docs"); Pkg.update(); Pkg.precompile()'

serve:
	$(JL) -e 'using Pkg; Pkg.activate("docs"); using LiveServer; servedocs(; skip_files=["docs/src/assets/indigo.css"])'

clean:
	rm -rf docs/build

.PHONY: init
