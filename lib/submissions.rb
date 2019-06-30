require_relative 'winnowing'
require 'json'

# TODO: Se já houver uma submissão do mesmo usuário para a mesma questão,
# atualizar ao invés de criar outra

# TODO: Implementar ignorar nomes de variável
class Submission
    attr_reader :timestamp, :content, :fingerprint, :hash_positions

    def initialize(user_id, question_id, content)
        @timestamp = Time.now
        @user_id = user_id
        @question_id = question_id
        @content = content
        @fingerprint, @marks = Winnowing.winnow(@content).to_a.transpose
    end

    def submit
        @simmilar ||= scan_simmilar()
        @name ||= $firebase.push('submissions', {
            timestamp: @timestamp,
            user_id: @user_id,
            question_id: @question_id,
            content: @content,
            fingerprint: @fingerprint,
            marks: @marks,
            simmilar: @simmilar
        }).body['name']

        update_simmilar
        @name
    end

    def update_simmilar
        @simmilar.keys.each do |submission|
            # TODO: Atualizar cada submissão detectada como similar para
            # incluir essa submissão em `simmilar`.
        end
    end

    def scan_simmilar
        request = $firebase.get('submissions', { 
            orderBy: '"question_id"',
            equalTo: @question_id.to_json
        })

        raise request.code unless request.success?

        entries = request.body
        matches = {}
        
        for id, submission in entries
            m = []
            for fp in @fingerprint
                m << fp if submission['fingerprint'].include? fp
            end

            unless m.empty?
                matches[id] = {
                    matches: m,
                    percentage: m.size.to_f / @fingerprint.size
                }
            end
        end

        matches
    end
end