<?xml version="1.0" encoding="iso-8859-1"?>

<!--
Parser_#5, an RDF to N-triples XSLT transform

Copyright � Max Froumentin, 2002.

Use and distribution of this code are permitted under the terms of the <a
href="http://www.w3.org/Consortium/Legal/copyright-software-19980720"
>W3C Software Notice and License</a>.
-->


<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform"
            xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            version="1.0">


  <output method="xml" encoding="US-ASCII" omit-xml-declaration="yes"/>

  <strip-space elements="*"/>

  <param name="base" select="''"/>

  <variable name="debug" select="0"/>

  <!-- if there's an xml:base attribute use it as the base URI, otherwise -->
  <!-- use the one passed as parameter $base -->

  <variable name="baseURI">
    <choose>
      <when test="rdf:RDF/@xml:base">
        <choose>
          <!-- if the baseURI has a fragment identifier, remove it -->
          <when test="contains(rdf:RDF/@xml:base,'#')">
            <value-of select="substring-before(rdf:RDF/@xml:base,'#')"/>
          </when>
          <otherwise>
            <value-of select="rdf:RDF/@xml:base"/>
          </otherwise>
        </choose>
      </when>
      <otherwise>
        <value-of select="$base"/>
      </otherwise>
    </choose>
  </variable>


  <variable name="rdfnsURI" select="'http://www.w3.org/1999/02/22-rdf-syntax-ns#'"/>

  <!-- ================================================================= -->
  <template match="/">
    <apply-templates/>
  </template>

  <!-- ================================================================= -->
  <template match="rdf:RDF">
    <apply-templates mode="node"/>
  </template>

  <!-- ================================================================= -->

  <template match="*" mode="node">
    <if test="$debug > 0">
      <text># N-triples for node: </text>
      <value-of select="concat(local-name(),'&#xa;')"/>
    </if>

    <if test="namespace-uri() = $rdfnsURI and
                  (@about or @resource or @type or @ID or @value)">
      <message>Warning: rdf attribute used without prefix</message>
    </if>


    <if test="not(self::rdf:Description)">
      <!-- n-triple for the type of this element -->
      <for-each select="@*[not(namespace-uri() = $rdfnsURI)]">
        <!-- subject: parent element's generate-id  -->
        <value-of select="concat('_:',generate-id(..),' ')"/>

        <!-- predicate: attribute name -->
      <value-of select="concat('&lt;',namespace-uri(),local-name(),'&gt;')" disable-output-escaping="yes"/>

      <!-- object: attribute value -->
      <value-of select="concat(' ',.,' .&#xa;')"/>

      </for-each>

      <!-- subject -->
      <choose>
        <when test="@rdf:about">
          <variable name="s">
            <call-template name="expand">
              <with-param name="base" select="$baseURI"/>
              <with-param name="there" select="@rdf:about"/>
            </call-template>
          </variable>
          <value-of select="concat('&lt;',$s,'&gt; ')" disable-output-escaping="yes"/>
        </when>
        <otherwise>
          <value-of select="concat('_:',generate-id(),' ')"/>
        </otherwise>
      </choose>

      <!-- predicate -->
      <value-of select="concat('&lt;',$rdfnsURI,'type&gt; ')"
        disable-output-escaping="yes"/>

      <!-- object -->
      <value-of select="concat('&lt;',namespace-uri(),local-name(),'&gt; .&#xa;')"
        disable-output-escaping="yes"/>
    </if>

    <if test="self::rdf:Description">
      <for-each select="@*[not(namespace-uri() = $rdfnsURI)]">

        <!-- subject, rdf:ID of parent element -->
        <value-of select="concat('&lt;',$baseURI,'#',../@rdf:ID,'&gt;')"
          disable-output-escaping="yes"/>

        <!-- predicate: name of attribute -->
        <value-of select="concat('&lt;',namespace-uri(),local-name(),'&gt;')"
          disable-output-escaping="yes"/>

        <!-- object: value of attribute -->
        <value-of select="concat('&quot;',.,'&quot; .&#xa;')"/>
      </for-each>
    </if>

    <!-- process the arcs -->
    <apply-templates mode="arc"/>
  </template>

  <!-- ==================================================================== -->

  <template match="*" mode="arc">
    <if test="$debug > 0">
      <text># N-triples for arc: </text>
      <value-of select="concat(local-name(),'&#xa;')"/>
    </if>

    <!-- 1st element of triple: subject (id of parent) -->
    <variable name="subject">
      <!-- we put the subject in a variable as it could be used later -->
      <!-- if we reify the statement -->
      <choose>
        <when test="../@rdf:about">
          <value-of select="concat('&lt;',../@rdf:about,'&gt;')"/>
        </when>

        <when test="../@rdf:ID">
          <value-of select="concat('&lt;',$baseURI,'#',../@rdf:ID,'&gt;')"/>
        </when>

        <otherwise>
          <!-- no ID or parent about: this is probably a bNode -->
          <value-of select="concat('_:',generate-id(..))"/>
        </otherwise>
      </choose>
    </variable>

    <!-- 2nd element: predicate (URI of node) -->
    <variable name="predicate">
      <choose>
        <when test="self::rdf:li">
          <value-of select="concat('&lt;',namespace-uri(),'_',count(preceding-sibling::rdf:li|.),'&gt;')"/>
        </when>
        <otherwise>
          <value-of select="concat('&lt;',namespace-uri(),local-name(),'&gt;')"/>
        </otherwise>
      </choose>


    </variable>


    <!-- 3rd element: object (URI or literal) -->
    <variable name="object">
      <choose>
        <when test="@rdf:parseType='Literal'">
          <value-of select="concat('xml&quot;',.,'&quot;')"/>
        </when>

        <when test="@rdf:parseType='Resource'">
          <value-of select="concat('_:',generate-id(.))"/>
        </when>

        <when test="@rdf:resource">
          <!-- target is a resource -->
          <variable name="r">
            <call-template name="expand">
              <with-param name="base" select="$baseURI"/>
              <with-param name="there" select="@rdf:resource"/>
            </call-template>
          </variable>

          <value-of select="concat('&lt;',$r,'&gt;')"/>

          <!--
          <value-of select="concat('&lt;',$baseURI,@rdf:resource,'&gt;')"/>
          -->
        </when>

        <when test="text()">
          <!-- target is a literal -->
          <value-of select="concat('&quot;',.,'&quot;')"/>
        </when>

        <!-- target is an RDF container rdf:Resource, rdf:Bag, -->
        <!-- rdf:Seq, rdf:Alt -->
        <!-- I assume those never have rdf:about -->
        <!--        <when test="namespace-uri(child::*)=$rdfnsURI">-->
        <when test="*">
          <value-of select="concat('_:',generate-id(child::*))"/>
        </when>

        <!-- arc has a child: it is the object, a bNode -->
        <!--
        <when test="*">
          <value-of select="concatgenerate-id(*[1])"/>
        </when>
-->
        <!-- arc has no target attributes or children -->
        <!-- object is then empty string -->
        <when test="not(@*[not(namespace-uri()=$rdfnsURI)])">
          <text>""</text>
        </when>
      </choose>
    </variable>

    <!-- if there's a reason to print this, do it -->
    <!-- how helpful the above line is -->
    <!-- basically, this test means: it the value of $object has been -->
    <!-- computed above, output the triple -->
    <!-- (there must be a more elegant way to do this) -->

    <if test="* or text() or @rdf:resource or not(@*[not(namespace-uri()=$rdfnsURI)])">
      <value-of select="concat($subject,' ')" disable-output-escaping="yes"/>
      <value-of select="concat($predicate,' ')" disable-output-escaping="yes"/>
      <value-of select="concat($object,' .&#xa;')" disable-output-escaping="yes"/>
    </if>

    <!-- if the current arc has non-rdf attributes, they are targets -->
    <!-- and a couple of n-triples must be generated for each -->
    <for-each select="@*[not(namespace-uri()=$rdfnsURI)]">
      <value-of select="concat($subject,' ')" disable-output-escaping="yes"/>
      <value-of select="concat($predicate,' ')" disable-output-escaping="yes"/>
      <value-of select="concat('_a:',generate-id(),' .&#xa;')"/>

      <value-of select="concat('_a:',generate-id(),' ')"/>
      <value-of select="concat('&lt;',namespace-uri(),local-name(),'&gt; ')"
        disable-output-escaping="yes"/>
      <value-of select="concat('&quot;',.,'&quot; .&#xa;')"/>
    </for-each>



    <!-- if target has an rdf:ID, the statement itself should be -->
    <!-- reified it seems. Not sure why (from example test0005.rdf) -->

    <if test="@rdf:ID">
      <!-- First n-triple: type -->

      <!-- subject -->
      <value-of select="concat('&lt;',$baseURI,'#',@rdf:ID,'&gt; ')"   disable-output-escaping="yes"/>
      <!-- predicate -->
      <value-of select="concat('&lt;',$rdfnsURI,'type&gt; ')"  disable-output-escaping="yes"/>
      <!-- object -->
      <value-of select="concat('&lt;',$rdfnsURI,'Statement&gt; .&#xa;')"   disable-output-escaping="yes"/>

      <!-- Second n-triple: subject -->

      <!-- subject -->
      <value-of select="concat('&lt;',$baseURI,'#',@rdf:ID,'&gt; ')"   disable-output-escaping="yes"/>
      <!-- predicate -->
      <value-of select="concat('&lt;',$rdfnsURI,'subject&gt; ')"   disable-output-escaping="yes"/>
      <!-- object -->
      <value-of select="concat($subject,' .&#xa;')"/>

      <!-- Second n-triple: predicate -->

      <!-- subject -->
      <value-of select="concat('&lt;',$baseURI,'#',@rdf:ID,'&gt; ')" disable-output-escaping="yes"/>
      <!-- predicate -->
      <value-of select="concat('&lt;',$rdfnsURI,'predicate&gt; ')"  disable-output-escaping="yes"/>
      <!-- object -->
      <value-of select="concat($predicate,' . &#xa;')"/>

      <!-- Third n-triple: object -->
      <!-- subject -->
      <value-of select="concat('&lt;',$baseURI,'#',@rdf:ID,'&gt; ')"  disable-output-escaping="yes"/>
      <!-- predicate -->
      <value-of select="concat('&lt;',$rdfnsURI,'object&gt; ')"  disable-output-escaping="yes"/>
      <!-- object -->
      <value-of select="concat($object,' . &#xa;')"/>

    </if>

    <!-- children could be one node (@@or more than one?)  or arcs -->
    <choose>
      <when test="@rdf:parseType='Resource'">
        <apply-templates mode="arc"/>
      </when>
      <when test="@rdf:parseType='Literal'">literal(<copy-of select="*"/>)</when>
      <otherwise>
        <apply-templates select="*" mode="node"/>
      </otherwise>
    </choose>
  </template>

<!--########################################################################-->
<!--########################################################################-->
<!--########################################################################-->
<!--########################################################################-->

  <!-- From here on, the templates are from Dan Connoly's URI
       absolutizer. They used to be <include>d but have been included
       to make users lifes simpler (few bugs fixed too)
   -->

<!--
<div xmlns="http://www.w3.org/1999/xhtml">

<h2>Share and Enjoy</h2>

<p>$ uri.xsl,v 1.6 2000/09/08 08:06:31 connolly Exp $</p>

<p>Copyright (c) 2000 W3C (MIT, INRIA, Keio), released under the <a
href="http://www.w3.org/Consortium/Legal/copyright-software-19980720">
W3C Open Source License</a> of August 14 1998.  </p>

<h2>Reference</h2>

<p><cite><a href="http://www.ietf.org/rfc/rfc2396.txt">Uniform
    Resource Identifiers (URI): Generic Syntax</a></cite> (RFC 2396)
    T. Berners-Lee, R. Fielding, L. Masinter August 1998 </p>

</div>
-->

<variable name="lowalpha"
	      select='"abcdefghijklmnopqrstuvwxyz"'/>
<variable name="upalpha"
	      select='"ABCDEFGHIJKLMNOPQRSTUVWXYZ"'/>
<variable name="digit"
	      select='"01234567890"'/>
<variable name="alpha"
	      select='concat($lowalpha, $upalpha)'/>

<param name="Debug" select="0"/>

<template name="expand">
  <!-- 5.2. Resolving Relative References to Absolute Form -->
  <param name="base"/> <!-- an absolute URI -->
  <param name="there"/> <!-- a URI reference -->

  <!-- @@assert that $there contains only URI characters -->
  <!-- @@implement the unicode->ascii thingy from HTML 4.0 -->

  <variable name="fragment" select='substring-after($there, "#")'/>
		<!-- hmm... I'd like to split after the *last* #,
		     but substring-after splits after the first occurence.
		     Anyway... more than one # is illegal -->

  <variable name="hashFragment">
    <choose>
      <when test="string-length($fragment) > 0">
        <value-of select='concat("#", $fragment)'/>
      </when>
      <otherwise>
        <value-of select='""'/>
      </otherwise>
    </choose>
  </variable>
  <variable name="rest"
		select='substring($there, 1,
			          string-length($there)
				  - string-length($hashFragment))'/>

  <if test="$Debug"><message>
     [<value-of select="$there"/>]
     [<value-of select="$fragment"/>]
     [<value-of select="$hashFragment"/>]
     [<value-of select="$rest"/>]
  </message></if>

  <choose>
    <!-- step 2) -->
    <when test="string-length($rest) = 0">
      <if test="0">
      <message>expand called with reference to self-same document.
			     should this be prohibited? i.e.
			     should the caller handle references
			     to the self-same document?</message>
      </if>
      <value-of select="concat($base, $hashFragment)"/>
    </when>

    <otherwise>
      <variable name="scheme">
        <call-template name="split-scheme">
	  <with-param name="ref" select="$rest"/>
	</call-template>
      </variable>

      <choose>
        <when test='string-length($scheme) > 0'>
	  <!-- step 3) ref is absolute. we're done -->
	  <value-of select="$there"/>
	</when>

        <otherwise>
	  <variable name="rest2"
			select='substring($rest, string-length($scheme) + 1)'/>

	  <variable name="baseScheme">
	    <call-template name="split-scheme">
	    <with-param name="ref" select="$base"/>
	    </call-template>
	  </variable>

	  <choose>
	    <when test='starts-with($rest2, "//")'>
	      <!-- step 4) network-path; we're done -->

	      <value-of select='concat($baseScheme, ":",
					   $rest2, $hashFragment)'/>
            </when>

	    <otherwise>

	      <variable name="baseRest"
			    select='substring($base,
				 string-length($baseScheme) + 2)'/>

	      <variable name="baseAuthority">
		<call-template name="split-authority">
		  <with-param name="ref" select="$baseRest"/>
		</call-template>
	      </variable>

	      <choose>
	        <when test='starts-with($rest2, "/")'>
		  <!-- step 5) absolute-path; we're done -->

		  <value-of select='concat($baseScheme, ":",
					       $baseAuthority,
					       $rest2, $hashFragment)'/>
		</when>

		<otherwise>
		  <!-- step 6) relative-path -->
		  <!-- @@ this part of the implementation is *NOT*
		       per the spec, because I want combine(wrt(x,y))=y
		       even in the case of y = foo/../bar
		       -->

		  <variable name="baseRest2"
			    select='substring($baseRest,
				 string-length($baseAuthority) + 1)'/>

		  <variable name="baseParent">
		    <call-template name="path-parent">
		      <with-param name="path" select="$baseRest2"/>
		    </call-template>
		  </variable>

		  <variable name="path">
		    <call-template name="follow-path">
		      <with-param name="start" select="$baseParent"/>
		      <with-param name="path" select="$rest"/>
		    </call-template>
		  </variable>

		  <if test="$Debug"><message>
		    step 6 rel
		     [<value-of select="$rest2"/>]
		     [<value-of select="$baseRest2"/>]
		     [<value-of select="$baseParent"/>]
		     [<value-of select="$path"/>]
		  </message></if>

		  <value-of select='concat($baseScheme, ":",
					       $baseAuthority,
					       $path,
					       $hashFragment)'/>
		</otherwise>
	      </choose>
	    </otherwise>
	  </choose>

        </otherwise>
      </choose>
    </otherwise>
  </choose>
</template>


<template name="split-scheme">
  <!-- from a URI reference -->
  <param name="ref"/>

  <variable name="scheme_"
		    select='substring-before($ref, ":")'/>
  <choose>
    <!-- test whether $scheme_ is a legal scheme name,
	 i.e. whether it starts with an alpha
	 and contains only alpha, digit, +, -, .
	 -->
    <when
      test='string-length($scheme_) > 0
            and contains($alpha, substring($scheme_, 1, 1))
	    and string-length(translate(substring($scheme_, 2),
			                concat($alpha, $digit,
					       "+-."),
				        "")) = 0'>
	  <value-of select="$scheme_"/>
    </when>

    <otherwise>
      <value-of select='""'/>
    </otherwise>
  </choose>
</template>


<template name="split-authority">
  <!-- from a URI reference that has had the fragment identifier
       and scheme removed -->
       <!-- cf 3.2. Authority Component -->

  <param name="ref"/>

  <choose>
    <when test='starts-with($ref, "//")'>
      <variable name="auth1" select='substring($ref, 3)'/>
      <variable name="auth2">
        <choose>
          <when test='contains($auth1, "?")'>
	    <value-of select='substring-before($auth1, "?")'/>
	  </when>
	  <otherwise><value-of select="$auth1"/>
	  </otherwise>
	</choose>
      </variable>

      <variable name="auth3">
        <choose>
          <when test='contains($auth2, "/")'>
	    <value-of select='substring-before($auth1, "/")'/>
	  </when>
	  <otherwise><value-of select="$auth2"/>
	  </otherwise>
	</choose>
      </variable>

      <value-of select='concat("//", $auth3)'/>
    </when>

    <otherwise>
      <value-of select='""'/>
    </otherwise>
  </choose>
</template>

<template name="follow-path">
  <param name="start"/> <!-- doesn't end with / ; may be empty -->
  <param name="path"/> <!-- doesn't start with / -->

  <if test="$Debug"><message>
    follow-path
     [<value-of select="$start"/>]
     [<value-of select="$path"/>]
  </message></if>

  <choose>
    <when test='starts-with($path, "./")'>
      <call-template name="follow-path">
        <with-param name="start" select="$start"/>
	<with-param name="path" select='substring($path, 3)'/>
      </call-template>
    </when>

    <when test='starts-with($path, "../")'>
      <call-template name="follow-path">
        <with-param name="start">
	  <call-template name="path-parent">
	    <with-param name="path" select="$start"/>
	  </call-template>
	</with-param>
	<with-param name="path" select='substring($path, 4)'/>
      </call-template>
    </when>

    <otherwise>
      <value-of select='concat($start, "/", $path)'/>
    </otherwise>
  </choose>
</template>


<template name="path-parent">
  <param name="path"/>

  <if test="$Debug"><message>
    path parent
     [<value-of select="$path"/>]
  </message></if>

  <choose>
	      <!-- foo/bar/    => foo/bar    , return -->
    <when test='substring($path, string-length($path)) = "/"'>
      <value-of select='substring($path, 1, string-length($path)-1)'/>
    </when>

	      <!-- foo/bar/baz => foo/bar/ba , recur -->
	      <!-- foo/bar/ba  => foo/bar/b  , recur -->
	      <!-- foo/bar/b   => foo/bar/   , recur -->
    <when test='contains($path, "/")'>
      <call-template name="path-parent">
        <with-param name="path"
		   select='substring($path, 1, string-length($path)-1)'/>
      </call-template>
    </when>

	      <!-- '' => '' -->
	      <!-- foo => '' -->
    <otherwise>
      <value-of select='""'/>
    </otherwise>

  </choose>

</template>

</stylesheet>
