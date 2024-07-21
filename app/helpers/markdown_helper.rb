 module MarkdownHelper 
    require "redcarpet"

    def markdown(text) 
        unless @markdown 
            options = {
                filter_htmml: true,
                hard_wrap: true,
                space_after_headers: true,
            }

            extentions = {
                autolink: true,
                no_intra_emphasis: true,
                fenced_code_blocks: true,
                tables: true,
            }
            renderer =  Redcarpet::Render::HTML.new(options) 
            @markdown = Redcarpet::Markdown.new(renderer, extentions) 
        end 

        @markdown.render(text).html_safe 
    end 
end 