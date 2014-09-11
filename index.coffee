through2 = require 'through2'

# requires = ['html', 'generate']

module.exports = (options = { shortname: null }) ->
    options = _.defaults options, {
        shortname: null
        disable_mobile: no
        category_id: null
    }

    if not options.shortname
        throw new TypeError 'You must specify a Disqus shortname to use'

    processFile = (file, enc, done) ->
        if file.isPost
            $ = file.$

            shortname = options.shortname
            url = file.url # @TODO: throw error
            title = file.title
            identifier = file.id # @TODO: throw error

            template = '
                <div id="disqus_thread">
                </div>
                <a href="http://disqus.com" class="dsq-brlink">
                    comments powered by
                    <span class="logo-disqus">Disqus</span>
                </a>
            '

            script = "
            <script>
                disqus_shortname = #{options.shortname}
                window.disqus_identifier = #{identifier}
                window.disqus_title = #{title}
                window.disqus_url = #{url}
                window.disqus_category_id = #{options.category_id}
                window.disqus_disable_mobile = #{options.disable_mobile}

                var dsq = document.createElement('script');
                dsq.type = 'text/javascript';
                dsq.async = true;
                dsq.src = '//#{shortname}.disqus.com/embed.js';

                (document.getElementsByTagName('head')[0] ||
                    document.getElementsByTagName('body')[0]).appendChild(dsq);
            </script>
            "


            file.comments =
                $(template)
                .attr 'shortname', shortname
                .attr 'url', url
                .attr 'title', title
                .attr 'identifier', identifier
                .append $(script)
                .html()

        done null, file

    through2.obj processFile