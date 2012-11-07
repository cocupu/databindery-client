client
======

Start a connection:
```ruby
Cocupu.start('email@example.com', 'password')
```

Attaching a file:
```ruby
attached = Cocupu::Node.new('persistent_id'=>'4d629a30-0a85-0130-6ce0-3c075405d3d7','url'=>'/foo/bar/nodes/4d629a30-0a85-0130-6ce0-3c075405d3d7').attach_file('Test', File.open('spec/fixtures/images/rails.png'))
attached.save
```
