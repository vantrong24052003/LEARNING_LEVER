---
description: Create a Rails API controller with create action only
argument-hint: resource_name | attributes
summary: Generate controller, routes, and model with create action
---

## Context

Parse $ARGUMENTS to extract:

- **resource**: Singular or plural resource name (example: user, users, product)
- **attributes**: List of attributes for strong params (example: name,email,password,status)

Normalize:
- Convert to singular PascalCase for model
- Convert to plural snake_case for controller

---

## Task

Generate Rails API code following the **exact same pattern as PostsController#create**.

### Controller

- File: `app/controllers/{plural_resource}_controller.rb`
- Class: `{PluralResource}Controller < ApplicationController`
- Use `render_success(response:, status:)` for success
- Use `render_error(error:, status:)` for errors

**Create action pattern:**
```ruby
def create
  @{resource} = {Model}.new(permit_params)

  if @{resource}.save
    render_success(response: @{resource}, status: :created)
  else
    render_error(error: @{resource}.errors.full_messages.join(", "), status: :unprocessable_entity)
  end
end

private

def permit_params
  params.require({resource}).permit(:attr1, :attr2, ...)
end
```

### Routes

- Update `config/routes.rb`
- Add: `resources :{plural_resource}, only: [:create]`

### Model

- File: `app/models/{resource}.rb`
- Add basic validations based on attributes
- Do NOT generate migrations

---

## Output Rules

- Generate code only (no explanations)
- Match existing project style exactly
