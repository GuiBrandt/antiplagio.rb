require 'winnowing'

RSpec.describe Winnowing, "#find_min" do
    context "starting at the beginning" do
        it "finds the index of the minimum value in an array" do
            a = [2, 4, 3, 1, 5]
            i = Winnowing.find_min(a)
            expect(i).to eq 3
        end

        context "with duplicated minimum values" do
            it "picks the rightmost ocurrence" do
                a = [2, 4, 3, 1, 5, 6, 7, 1]
                i = Winnowing.find_min(a)
                expect(i).to eq 7
            end
        end
    end

    context "with some offset" do
        offset = 2

        it "finds the index of the minimum value in an array" do
            a = [2, 4, 3, 1, 5]
            i = Winnowing.find_min(a, offset)
            expect(i).to eq 3
        end

        it "ignores elements from before the offset" do
            a = [2, 0, 2, 1, 5]
            i = Winnowing.find_min(a, offset)
            expect(i).to eq 3
        end
    end
end

# Segue a seção "2.1 Desirable properties" e a definição das propriedades do
# winnowing em "3.WINNOWING" do paper de Schleimer et. al
RSpec.describe Winnowing, "#winnow" do
    it "returns an Enumerator" do
        Winnowing.winnow('test' * 100).is_a? Enumerator
    end

    it "ignores whitespaces" do
        a, = Winnowing.winnow('abc def ghi jkl' * 5).to_a.transpose
        b, = Winnowing.winnow('abcdefghijkl' * 5).to_a.transpose
        expect(a).to eq b
    end

    it "ignores case" do
        a, = Winnowing.winnow('ABC DEF GHI JKL' * 5).to_a.transpose
        b, = Winnowing.winnow('abc def ghi jkl' * 5).to_a.transpose
        expect(a).to eq b
    end

    def matches?(a, b)
        found = false
        for i in a
            for j in b
                if i == j
                    found = true
                    break
                end
            end
        end
        found
    end

    it "supresses noise" do
        a, = Winnowing.winnow('abc 123 abc 456 987 342 32 54 abc foo bar baz').to_a.transpose
        b, = Winnowing.winnow('abc the quick brown abc fox jumps over the abc lazy dog').to_a.transpose

        expect(matches?(a, b)).to be false
    end

    it "deals with changes in position" do
        a, = Winnowing.winnow('the quick brown fox jumps over the lazy dog').to_a.transpose
        b, = Winnowing.winnow('quick and brown, the fox does a jump over the dog who is lazy').to_a.transpose

        expect(matches?(a, b)).to be true
    end

    it "detects matches with length >= the guarantee threshold" do
        guarantee = '0' * Winnowing::GUARANTEE_THRESHOLD
        str_a = "aaaaaaaaaaaaaaaa#{guarantee}aaaaaaaaaaaaaaaaa"
        str_b = "bbbbbbbbbbbbbbbb#{guarantee}bbbbbbbbbbbbbbbbb"

        a, = Winnowing.winnow(str_a).to_a.transpose
        b, = Winnowing.winnow(str_b).to_a.transpose

        expect(matches?(a, b)).to be true
    end

    it "ignores matches with length <= the noise threshold" do
        noise = '0' * Winnowing::NOISE_THRESHOLD
        str_a = "aaaaaaaaaaaaaaaa#{noise}aaaaaaaaaaaaaaaaa"
        str_b = "bbbbbbbbbbbbbbbb#{noise}bbbbbbbbbbbbbbbbb"

        a, = Winnowing.winnow(str_a).to_a.transpose
        b, = Winnowing.winnow(str_b).to_a.transpose

        expect(matches?(a, b)).to be false
    end
end