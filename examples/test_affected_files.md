1. collect execution info

Add below code to top of the spec_helper.rb

``` ruby
require 'crystalball'

if ENV['CRYSTALBALL'] == 'true'
  Crystalball::MapGenerator.start! do |config|
    config.register Crystalball::MapGenerator::CoverageStrategy.new
  end
end

```

2. run request test by

`CRYSTALBALL=true rspec ./spec/requests/`

3. init analyzer

``` ruby
path = "#{Dir.pwd}/analysis/"
analyzor = RtsRB::Analyzor.new(path)
analyzor.load; analyzor.file_level
```

4. analysis affected files

``` ruby
files = affected-files-in-pr
analyzor.affected_specs(files)
```

