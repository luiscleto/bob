{{$table := .Table}}
{{ $tAlias := .Aliases.Table $table.Key -}}

{{range $.Relationships.Get $table.Key -}}
{{- if not .IsToMany -}}{{continue}}{{end -}}
{{- $ftable := $.Aliases.Table .Foreign -}}
{{- $relAlias := $tAlias.Relationship .Name -}}
{{- $type := printf "*%sTemplate" $ftable.UpSingular -}}


func (m {{$tAlias.DownSingular}}Mods) With{{$relAlias}}(number int, {{$.Tables.RelDependencies $.Aliases . "" "Template"}} related {{$type}}) {{$tAlias.UpSingular}}Mod {
	return {{$tAlias.UpSingular}}ModFunc(func (ctx context.Context, o *{{$tAlias.UpSingular}}Template) {
		o.r.{{$relAlias}} = []*{{$tAlias.DownSingular}}R{{$relAlias}}R{ {
			number: number,
			o: related,
			{{$.Tables.RelDependenciesTypSet $.Aliases .}}
		}}
	})
}

func (m {{$tAlias.DownSingular}}Mods) WithNew{{$relAlias}}(number int, mods ...{{$ftable.UpSingular}}Mod) {{$tAlias.UpSingular}}Mod {
	return {{$tAlias.UpSingular}}ModFunc(func (ctx context.Context, o *{{$tAlias.UpSingular}}Template) {
    {{range $.Tables.NeededBridgeRels . -}}
			{{$alias := $.Aliases.Table .Table -}}
			{{$alias.DownSingular}}{{.Position}} := o.f.New{{$alias.UpSingular}}WithContext(ctx)
		{{end}}

		related := o.f.New{{$ftable.UpSingular}}WithContext(ctx, mods...)
		m.With{{$relAlias}}(number, {{$.Tables.RelArgs $.Aliases .}} related).Apply(ctx, o)
	})
}

func (m {{$tAlias.DownSingular}}Mods) Add{{$relAlias}}(number int, {{$.Tables.RelDependencies $.Aliases . "" "Template"}} related {{$type}}) {{$tAlias.UpSingular}}Mod {
	return {{$tAlias.UpSingular}}ModFunc(func (ctx context.Context, o *{{$tAlias.UpSingular}}Template) {
		o.r.{{$relAlias}} = append(o.r.{{$relAlias}}, &{{$tAlias.DownSingular}}R{{$relAlias}}R{
			number: number,
			o: related,
			{{$.Tables.RelDependenciesTypSet $.Aliases .}}
		})
	})
}

func (m {{$tAlias.DownSingular}}Mods) AddNew{{$relAlias}}(number int, mods ...{{$ftable.UpSingular}}Mod) {{$tAlias.UpSingular}}Mod {
	return {{$tAlias.UpSingular}}ModFunc(func (ctx context.Context, o *{{$tAlias.UpSingular}}Template) {
    {{range $.Tables.NeededBridgeRels . -}}
			{{$alias := $.Aliases.Table .Table -}}
			{{$alias.DownSingular}}{{.Position}} := o.f.New{{$alias.UpSingular}}WithContext(ctx)
		{{end}}

		related := o.f.New{{$ftable.UpSingular}}WithContext(ctx, mods...)
		m.Add{{$relAlias}}(number, {{$.Tables.RelArgs $.Aliases .}} related).Apply(ctx, o)
	})
}

func (m {{$tAlias.DownSingular}}Mods) AddExisting{{$relAlias}}(existingModels ...*models.{{$ftable.UpSingular}}) {{$tAlias.UpSingular}}Mod {
	return {{$tAlias.UpSingular}}ModFunc(func (ctx context.Context, o *{{$tAlias.UpSingular}}Template) {
    for _, em := range existingModels {
      o.r.{{$relAlias}} = append(o.r.{{$relAlias}}, &{{$tAlias.DownSingular}}R{{$relAlias}}R{
        o: o.f.FromExisting{{$ftable.UpSingular}}(em),
      })
    }
	})
}

func (m {{$tAlias.DownSingular}}Mods) Without{{$relAlias}}() {{$tAlias.UpSingular}}Mod {
	return {{$tAlias.UpSingular}}ModFunc(func (ctx context.Context, o *{{$tAlias.UpSingular}}Template) {
			o.r.{{$relAlias}} = nil
	})
}

{{end}}
