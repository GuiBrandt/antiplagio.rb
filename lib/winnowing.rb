# Baseado no paper sobre fingerprinting de documentos digitais de Schleimer et. al
# Disponível em: http://theory.stanford.edu/~aiken/publications/papers/sigmod03.pdf

require 'xxhash'

XXHASH_SEED = 42

module Winnowing
    GUARANTEE_THRESHOLD = 8
    NOISE_THRESHOLD = 5
    WINDOW_SIZE = GUARANTEE_THRESHOLD - NOISE_THRESHOLD + 1

    class WindowedHashString
        K = NOISE_THRESHOLD

        def initialize(string)
            @string, @position_map = clean(string)
        end

        # TODO: Otimizar. De preferência não usar regex em cada caractere
        def clean(string)
            result = ""
            removed = []
    
            string.chars.each_with_index do |c, i| 
                if c =~ /\w/
                    result << c.downcase
                else
                    removed << result.size
                end
            end
    
            return result, removed
        end

        def hashes
            Enumerator.new do |enum|
                for offset in 0..(@string.size - K)
                    enum.yield XXhash.xxh32(@string[offset, K], XXHASH_SEED)
                end
            end
        end

        def windows
            h = hashes()
            window = Array.new(WINDOW_SIZE) { h.next }
    
            Enumerator.new do |enum|
                begin
                    loop do
                        enum.yield window
                        window.shift
                        window << h.next
                    end
                rescue StopIteration
                end
            end
        end

        def adjust_position(pos, start = 0)
            i = start
            i += 1 while i < @position_map.size and @position_map[i] <= pos
            i
        end
    end

    def self.find_min(window, start = 0)
        argmin = start
        for j in 1..(window.size - start)
            argmin = window.size - j if window[-j] < window[argmin]
        end
        argmin
    end

    def self.winnow(text)
        Enumerator.new do |enum|
            processed = WindowedHashString.new(text)
            argmin = 0
            pos = 0
            for window, i in processed.windows.with_index
                argmin -= 1

                if argmin < 0
                    argmin = find_min(window)
                else
                    argmin_ = find_min(window, argmin)
                    next if argmin_ == argmin
                    argmin = argmin_
                end

                pos = processed.adjust_position(argmin + i, pos)
                enum.yield window[argmin], argmin + i + pos
            end
        end
    end
end