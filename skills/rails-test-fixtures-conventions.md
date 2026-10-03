# Rails Test Fixtures

Goal: keep fixtures few. Too many fixtures = nobody understands the dependency graph.

## Rules

1. **1-2 fixtures per model max**
    - Name them `:one` and `:two`
    - Plain, valid, boring attributes
    - Minimal dependencies
    - Add `:two` only to compare two records

2. **Customize in the test, not the fixture**
    - `developers(:one).update!(field: value)`
    - Only set the field the test cares about
    - Extra DB write is fine, readability wins

3. **Use a custom helper method for when needed**
    - Create a method like `create_thing` that allows customizing attributes

4. **New named fixture = last resort**
    - Only for deep/complex required associations
    - Give it a real name, not `:three` (e.g. `:paying_customer`)
    - Max 1-2 per model