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
        puts "error file_missing '#{f}'"
        exit(1)
    end
end

alphabet = File.readlines("#{name}.alphabet", chomp: true)
final_states = File.readlines("#{name}.final_states", chomp: true)
states = File.readlines("#{name}.states", chomp: true)
transitions = File.readlines("#{name}.transitions", chomp: true).map do |arr|
    toks = arr.split(' ')
    {
        state: toks[0],
        letter: toks[1],
        result_state: toks[2]
    }
end

inputstr = File.readlines(inputfile, chomp: true)

if !states.include?(startstate)
    puts "error unknown_state '#{startstate}'"
    exit(1)
end

threads = []

threads << { state: startstate, name: '0' }

inputstr.each_with_index do |x, i|
    alive_threads = []

    puts "ok movenext '#{x}' pos #{i}"

    threads.each do |thread|

        if final_states.include?(thread[:state])
            puts "ok completed #{thread[:name]}"
            next
        end
    
        if !alphabet.include?(x)
            puts "error unexpected_letter #{thread[:name]} letter '#{x}' position '#{i}'"
            next
        end
    
        child_list = []
        transitions.each do |t|
            next unless t[:state] == thread[:state] && t[:letter] == x

            ntname = thread[:name] + child_list.count.to_s
            puts "ok transition #{ntname} state '#{thread[:state]}' letter '#{x}' state '#{t[:result_state]}'"
            new_thread = {
                state: t[:result_state],
                name: ntname
            }
    
            child_list << new_thread
            transited = true
        end
    
        if child_list.length.zero?
            puts "error no_known_transition #{thread[:name]} state '#{thread[:state]}' letter '#{x}'"
            next
        end

        puts "ok forked #{thread[:name]} to #{child_list.map{|x| x[:name]}.join(',')}" if child_list.length > 1

        alive_threads += child_list
    end

    threads = alive_threads.each_with_index.map do |thethread, i|
        oldname = thethread[:name]
        newname = i.to_s
        puts "ok convert '#{oldname}' '#{newname}'" if oldname != newname

        { state: thethread[:state], name: newname }
    end

end

puts "ok no_more_input"

threads.each do |thread|
    puts "ok incomplete #{thread[:name]} state '#{thread[:state]}'"
end
