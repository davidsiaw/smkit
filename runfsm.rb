name = ARGV[0]
inputfile = ARGV[1]
startstate = ARGV[2]

EXTS = %w[
    alphabet
    final_states
    states
    transitions
]

# check all files exist
EXTS.each do |x|
    f = "#{name}.#{x}"
    if !File.exist?(f)
        puts "Required file #{f} missing"
        exit(1)
    end
end

alphabet = File.read("#{name}.alphabet").split("\n")
final_states = File.read("#{name}.final_states").split("\n")
states = File.read("#{name}.states").split("\n")
transitions = File.read("#{name}.transitions").split("\n").map do |arr|
    toks = arr.split(' ')
    {
        state: toks[0],
        letter: toks[1],
        result_state: toks[2]
    }
end

inputstr = File.read(inputfile).split("\n")

if !states.include?(startstate)
    puts "Unknown state '#{startstate}'"
    exit(1)
end

state = startstate

inputstr.each_with_index do |x,i|
    if !alphabet.include?(x)
        puts "Unexpected letter '#{x}' at position #{i}"
        exit(1)
    end

    transition = transitions.select do |t|
        t[:state] == state && t[:letter] == x
    end.first

    if transition.nil?
        puts "Don't know how to transition from state '#{state}' on letter '#{x}'"
        exit(1)
    end

    puts "Transition from '#{state}' to '#{transition[:result_state]}' on '#{x}'"
    state = transition[:result_state]
end

if !final_states.include?(state)
    puts "Invalid final state '#{state}'"
    exit(1)
end

puts 'Completed'
