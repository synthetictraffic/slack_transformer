module SlackTransformer
  class Slack
    class Code
      attr_reader :input

      # Original pattern for inline code
      INLINE_PATTERN = /
        (?<=^|\W|_)

        # preceded by start of line, non-word character, or _

        (?<!`)

        # but not `

        `([^`]+?)(`+)

        # one or more of not ` preceded by ` followed by one or more `
      /x

      # New pattern for multi-line code blocks - Match only triple backticks at line start and end
      MULTILINE_PATTERN = /^```\n(.*?)\n```$/m

      def initialize(input)
        @input = input
      end

      def to_html
        # Check if input is a complete multi-line code block
        if input.strip =~ /^```\n.*\n```$/m
          # Process as a complete multi-line code block
          result = input.gsub(MULTILINE_PATTERN) do |_|
            inner_text = Regexp.last_match(1)
            # Ensure we don't have a trailing newline in the output
            "<pre><code>#{inner_text}</code></pre>"
          end.chomp
        else
          # Otherwise, handle as regular input
          result = input.dup
        end

        # Then, process inline code (using the original logic)
        final_result = result.gsub(INLINE_PATTERN) do |match|
          closing_backticks = Regexp.last_match(2)
          closing_backticks_length = closing_backticks.length
          closing_backticks_remainder = closing_backticks_length % 3

          if closing_backticks_remainder == 0
            match
          else
            inner_text = Regexp.last_match(1)
            inner_trailing_backticks = '`' * (closing_backticks_length / 3 * 3)
            outer_trailing_backticks = '`' * (closing_backticks_remainder - 1)

            "<code>#{inner_text}#{inner_trailing_backticks}</code>#{outer_trailing_backticks}"
          end
        end

        # Ensure no trailing newline in the final result
        final_result.chomp
      end
    end
  end
end