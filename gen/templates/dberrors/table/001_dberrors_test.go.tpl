{{if or .Table.Constraints.Uniques }}
{{$table := .Table}}
{{$tAlias := .Aliases.Table $table.Key}}
{{$.Importer.Import "context"}}
{{$.Importer.Import "errors"}}
{{$.Importer.Import "testing"}}
{{$.Importer.Import "models" (index $.OutputPackages "models") }}
{{$.Importer.Import "factory" (index $.OutputPackages "factory") }}
{{$.Importer.Import "github.com/stephenafamo/bob"}}

func Test{{$tAlias.UpSingular}}UniqueConstraintErrors(t *testing.T) {
	if testDB == nil {
		t.Skip("No database connection provided")
	}

	f := factory.New()
	tests := []struct{
		name        string
		expectedErr   *UniqueConstraintError
		conflictMods  func(context.Context, *testing.T, bob.Executor, *models.{{$tAlias.UpSingular}}) factory.{{$tAlias.UpSingular}}ModSlice
	}{
	{{range $index := (prepend $table.Constraints.Uniques $table.Constraints.Primary)}}
		{{- $errName := printf "ErrUnique%s" ($index.Name | camelcase) -}}
		{
			name: "{{$errName}}",
			expectedErr: {{$tAlias.UpSingular}}Errors.{{$errName}},
			conflictMods: func(ctx context.Context, t *testing.T, exec bob.Executor, obj *models.{{$tAlias.UpSingular}}) factory.{{$tAlias.UpSingular}}ModSlice {
        shouldUpdate := false
        updateMods := make(factory.{{$tAlias.UpSingular}}ModSlice, 0, {{len $index.Columns}})

        {{range $indexColumn := $index.Columns}}
          {{- $colAlias := $tAlias.Column $indexColumn -}}
          {{- $column := $table.GetColumn $indexColumn -}}
          {{if $column.Nullable -}}
          if !{{$.Types.GetNullTypeValid $.CurrentPackage $column.Type (cat "obj." $colAlias)}} {
            shouldUpdate = true
            updateMods = append(updateMods, factory.{{$tAlias.UpSingular}}Mods.Random{{$colAlias}}NotNull(nil))
          }
          {{- end}}
        {{end}}

        if shouldUpdate {
          if err := obj.Update(ctx, exec, f.New{{$tAlias.UpSingular}}WithContext(ctx, updateMods...).BuildSetter()); err != nil {
            t.Fatalf("Error updating object: %v", err)
          }
        }

        return factory.{{$tAlias.UpSingular}}ModSlice{
          {{range $indexColumn := $index.Columns}}
            {{- $colAlias := $tAlias.Column $indexColumn -}}
            {{- $column := $table.GetColumn $indexColumn -}}
            factory.{{$tAlias.UpSingular}}Mods.{{$colAlias}}(obj.{{$colAlias}}),
          {{end}}
        }
			},
		},
	{{end}}
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
      ctx, cancel := context.WithCancel(t.Context())
      t.Cleanup(cancel)

			tx, err := testDB.Begin(ctx)
			if err != nil {
				t.Fatalf("Couldn't start database transaction: %v", err)
			}

      defer func() {
        if err := tx.Rollback(ctx); err != nil {
          t.Fatalf("Error rolling back transaction: %v", err)
        }
      }()

      var exec bob.Executor = tx

			obj, err := f.New{{$tAlias.UpSingular}}WithContext(ctx, factory.{{$tAlias.UpSingular}}Mods.WithParentsCascading()).Create(ctx, exec)
			if err != nil {
				t.Fatal(err)
			}

			obj2, err := f.New{{$tAlias.UpSingular}}WithContext(ctx).Create(ctx, exec)
			if err != nil {
				t.Fatal(err)
			}

      err = obj2.Update(ctx, exec, f.New{{$tAlias.UpSingular}}WithContext(ctx, tt.conflictMods(ctx, t, exec, obj)...).BuildSetter())
			if !errors.Is(ErrUniqueConstraint, err) {
				t.Fatalf("Expected: %s, Got: %v", tt.name, err)
			}
			if !errors.Is(tt.expectedErr, err) {
				t.Fatalf("Expected: %s, Got: %v", tt.expectedErr.Error(), err)
			}
			if !ErrUniqueConstraint.Is(err) {
				t.Fatalf("Expected: %s, Got: %v", tt.name, err)
			}
			if !tt.expectedErr.Is(err) {
				t.Fatalf("Expected: %s, Got: %v", tt.expectedErr.Error(), err)
			}
		})
	}
}
{{end -}}
