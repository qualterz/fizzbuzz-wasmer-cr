require "wasmer"

module Wasmer::FizzBuzz
  VERSION = "0.1.0"

  # Get module file paths from the program arguments.
  wasm_files = ARGV

  if wasm_files.empty?
    abort "At least one module is required to continue."
  end

  # Define the default engine store.
  store = Wasmer.default_engine.new_store

  # Compile the modules to be able to execute them!
  wasm_modules = wasm_files.compact_map { |file|
    begin
      Wasmer::Module.new store, File.read(file)
    rescue
      puts "Failed to load #{file} module."
    end
  }

  if wasm_modules.empty?
    abort "No loaded modules to continue."
  end

  puts "#{wasm_modules.size} modules are loaded."

  functions = wasm_modules.compact_map { |wasm|
    # Instantiate a compiled module.
    instance = Wasmer::Instance.new wasm

    # Get the exported `handle` function.
    function = instance.function("handle")
  }

  if functions.empty?
    abort "No loaded functions to continue."
  end

  puts "#{functions.size} functions are loaded."

  # Process the core logic
  Int32::MAX.times { |number|
    puts "Calling functions on #{number}:"
  
    functions.each &.call(number)

    sleep 1.second
  }
end
