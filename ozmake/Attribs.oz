functor
export
   'class' : Attribs
import
   Property
   Resolve
   OS
   Path  at 'Path.ozf'
   Utils at 'Utils.ozf'
define
   class Attribs
      attr
         Prefix     : unit
         Dir        : unit
         BuildDir   : unit
         SrcDir     : unit
         BinDir     : unit
         LibDir     : unit
         DocDir     : unit
         LibRoot    : unit
         DocRoot    : unit
         MakeFile   : unit
         MakeFileGiven : false
         Uri        : unit
         Mogul      : unit
         ExtractDir : unit
         Database   : unit
         DatabaseGiven : false
         Released   : unit
         Clean      : unit
         Veryclean  : unit
         Author     : unit
         BinTargets : nil
         LibTargets : nil
         DocTargets : nil
         SrcTargets : nil
         FullBuild  : false     % if true, also build targets in src
         Blurb      : unit
         InfoText   : unit
         InfoHtml   : unit
         Verbose    : false
         Quiet      : false
         JustPrint  : false
         OptLevel   : optimize
         Grade      : none
         ReplaceFiles : false
         KeepZombies: false
         SaveDB     : true
         IncludeDocs: true
         IncludeLibs: true
         IncludeBins: true
         ExtendPkg  : false
         GNU        : unit
         Package    : unit
         PackageGiven:false
         PublishDir : unit
         Archive    : 'http://www.mozart-oz.org/mogul/pkg'
         LineWidth  : 70
         NoMakefile : true
         Local      : false
         %% support for recursing into subdirs
         Subdirs    : nil       % list of subdirs
         AsSubdir   : unit      % name of current directory
         Submans    : unit      % managers for subdirectories
         Superman   : unit      % manager for parent directory
         Submakefiles:unit
         IncludeDirs: nil
         LibraryDirs: nil
         %% tools
         OzEngine   : unit
         OzC        : unit
         OzL        : unit
         OzTool     : unit
         ResolverExtended : false

      meth set_prefix(D) Prefix<-{Path.expand D} end
      meth get_prefix($)
         if @Prefix==unit then
            if @Superman\=unit then
               Prefix<-{@Superman get_prefix($)}
            else
               Prefix<-{Path.expand
                        {Path.resolve
                         {Property.get 'user.home'} '.oz'}}
            end
         end
         @Prefix
      end

      meth set_dir(D) Dir<-{Path.expand D} end

      meth set_builddir(D) BuildDir<-{Path.expand D} end
      meth get_builddir($)
         if @BuildDir==unit then
            if @Superman\=unit then
               BuildDir<-{Path.resolve {@Superman get_builddir($)} @AsSubdir}
            elseif @Dir\=unit then
               BuildDir<-@Dir
            else
               BuildDir<-nil
            end
         end
         @BuildDir
      end

      meth set_srcdir(D) SrcDir<-{Path.expand D} end
      meth get_srcdir($)
         if @SrcDir==unit then
            if @Superman\=unit then
               SrcDir<-{Path.resolve {@Superman get_srcdir($)} @AsSubdir}
            elseif @Dir\=unit then
               SrcDir<-@Dir
            elseif @MakeFile\=unit then
               SrcDir<-{Path.dirname @MakeFile}
            else
               SrcDir<-nil
            end
         end
         @SrcDir
      end

      meth set_libroot(D) LibRoot<-{Path.expand D} end
      meth get_libroot($)
         if @LibRoot==unit then
            if @Superman\=unit then
               LibRoot<-{@Superman get_libroot($)}
            else
               LibRoot<-{Path.resolve Attribs,get_prefix($) 'cache'}
            end
         end
         @LibRoot
      end

      meth set_libdir(D) LibDir<-{Path.expand D} end
      meth get_libdir($)
         if @LibDir==unit then
            if @Superman\=unit then
               LibDir<-{Path.resolve {@Superman get_libdir($)} @AsSubdir}
            else
               LibDir<-{Path.resolve Attribs,get_libroot($)
                        {Path.toCache Attribs,get_uri($)}}
            end
         end
         @LibDir
      end

      meth set_bindir(D) BinDir<-{Path.expand D} end
      meth get_bindir($)
         if @BinDir==unit then
            if @Superman\=unit then
               BinDir<-{@Superman get_bindir($)}
            else
               BinDir<-{Path.resolve Attribs,get_prefix($) 'bin'}
            end
         end
         @BinDir
      end

      meth set_docroot(D) DocRoot<-{Path.expand D} end
      meth get_docroot($)
         if @DocRoot==unit then
            if @Superman\=unit then
               DocRoot<-{@Superman get_docroot($)}
            else
               DocRoot<-{Path.resolve Attribs,get_prefix($) 'doc'}
            end
         end
         @DocRoot
      end

      meth set_docdir(D) DocDir<-{Path.expand D} end
      meth get_docdir($)
         if @DocDir==unit then
            if @Superman\=unit then
               DocDir<-{Path.resolve {@Superman get_docdir($)} @AsSubdir}
            else
               DocDir<-{Path.resolve Attribs,get_docroot($)
                        {Utils.mogulToFilename Attribs,get_mogul($)}}
            end
         end
         @DocDir
      end

      meth set_uri(U) Uri<-U end
      meth get_uri($)
         if @Uri==unit andthen @Superman\=unit then
            Uri<-{Path.resolveAtom {@Superman get_uri($)} @AsSubdir}
         end
         if @Uri==unit then raise ozmake(get_uri) end else @Uri end
      end

      meth set_mogul(M) Mogul<-M end
      meth get_mogul($)
         if @Mogul==unit andthen @Superman\=unit then
            Mogul<-{@Superman get_mogul($)}
         end
         if @Mogul==unit then raise ozmake(get_mogul) end
         else @Mogul end
      end

      meth set_extractdir(D) ExtractDir<-{Path.expand D} end
      meth get_extractdir($)
         if @ExtractDir==unit then
            ExtractDir<-Attribs,get_builddir($)
         end
         @ExtractDir
      end

      meth set_makefile(F)
         MakeFile<-{Path.expand F}
         MakeFileGiven<-true
      end
      meth get_makefile($)
         if @MakeFile==unit andthen @Superman\=unit then
            M={@Superman get_makefile($)}
            D={Path.dirname M}
            B={Path.basename M}
         in
            MakeFile<-{Path.resolve {Path.resolve D @AsSubdir} B}
         end
         if @MakeFile==unit then
            %% get_srcdir cannot call get_makefile but must look at
            %% @MakeFile directly
            MakeFile<-{Path.resolve Attribs,get_srcdir($) 'makefile.oz'}
         end
         @MakeFile
      end
      meth get_makefile_given($)
         if @Superman\=unit then
            {@Superman get_makefile_given($)}
         else @MakeFileGiven end
      end

      meth set_database(F)
         Database<-{Path.expand F}
         DatabaseGiven<-true
      end
      meth get_database($)
         if @Database==unit then
            if @Superman\=unit then
               Database<-{@Superman get_database($)}
            else
               Database<-{Path.resolve Attribs,get_prefix($) 'DATABASE'}
            end
         end
         @Database
      end
      meth get_database_given($)
         if @Superman\=unit then
            {@Superman get_database_given($)}
         else @DatabaseGiven end
      end

      meth set_released(D) Released<-D end
      meth get_released($)
         if @Released==unit andthen @Superman\=unit then
            Released<-{@Superman get_released($)}
         end
         @Released
      end

      meth set_clean(L) Clean<-L end
      meth get_clean($)
         if @Clean==unit andthen @Superman\=unit then
            Clean<-{@Superman get_clean($)}
         end
         @Clean
      end

      meth set_veryclean(L) Veryclean<-L end
      meth get_veryclean($)
         if @Veryclean==unit andthen @Superman\=unit then
            Veryclean<-{@Superman get_veryclean($)}
         end
         @Veryclean
      end

      meth set_author(L) Author<-L end
      meth get_author($)
         if @Author==unit andthen @Superman\=unit then
            Author<-{@Superman get_author($)}
         end
         @Author
      end

      meth get_oz_home($) {Path.expand {Property.get 'oz.home'}} end
      meth get_oz_bindir($) {Path.resolve Attribs,get_oz_home($) 'bin'} end
      meth get_oz_engine($)
         if @OzEngine==unit then
            P={Path.resolveAtom Attribs,get_oz_bindir($) 'ozengine.exe'}
         in
            if {Path.exists P} then OzEngine<-P else
               OzEngine<-{Path.resolveAtom Attribs,get_oz_bindir($) 'ozengine'}
            end
         end
         @OzEngine
      end
      meth get_oz_ozc($)
         if @OzC==unit then
            P={Path.resolveAtom Attribs,get_oz_bindir($) 'ozc.exe'}
         in
            if {Path.exists P} then OzC<-P else
               OzC<-{Path.resolveAtom Attribs,get_oz_bindir($) 'ozc'}
            end
         end
         @OzC
      end
      meth get_oz_ozl($)
         if @OzL==unit then
            P={Path.resolveAtom Attribs,get_oz_bindir($) 'ozl.exe'}
         in
            if {Path.exists P} then OzL<-P else
               OzL<-{Path.resolveAtom Attribs,get_oz_bindir($) 'ozl'}
            end
         end
         @OzL
      end
      meth get_oz_oztool($)
         if @OzTool==unit then
            P={Path.resolveAtom Attribs,get_oz_bindir($) 'oztool.exe'}
         in
            if {Path.exists P} then OzTool<-P else
               OzTool<-{Path.resolveAtom Attribs,get_oz_bindir($) 'oztool'}
            end
         end
         @OzTool
      end

      meth set_bin_targets(L) BinTargets<-L end
      meth get_bin_targets($) @BinTargets end
      meth set_lib_targets(L) LibTargets<-L end
      meth get_lib_targets($) @LibTargets end
      meth set_doc_targets(L) DocTargets<-L end
      meth get_doc_targets($) @DocTargets end
      meth set_src_targets(L) SrcTargets<-L end
      meth get_src_targets($) @SrcTargets end

      meth set_fullbuild(B) FullBuild<-B end
      meth get_fullbuild($)
         if @Superman\=unit
         then {@Superman get_fullbuild($)}
         else @FullBuild end
      end

      meth set_blurb(S) Blurb<-S end
      meth get_blurb($) @Blurb end
      meth set_info_text(S) InfoText<-S end
      meth get_info_text($) @InfoText end
      meth set_info_html(S) InfoHtml<-S end
      meth get_info_html($) @InfoHtml end

      meth set_verbose(B) Verbose<-B end
      meth get_verbose($)
         if @Superman\=unit
         then {@Superman get_verbose($)}
         else @Verbose end
      end
      meth set_quiet(B) Quiet<-B end
      meth get_quiet($)
         if @Superman\=unit
         then {@Superman get_quiet($)}
         else @Quiet end
      end
      meth set_justprint(B) JustPrint<-B end
      meth get_justprint($)
         if @Superman\=unit
         then {@Superman get_justprint($)}
         else @JustPrint end
      end
      meth set_optlevel(O) OptLevel<-O end
      meth get_optlevel($)
         if @Superman\=unit
         then {@Superman get_optlevel($)}
         else @OptLevel end
      end

      meth set_grade(G) Grade<-G end
      meth get_grade($)
         if @Superman\=unit
         then {@Superman get_grade($)}
         else @Grade end
      end

      meth set_replacefiles(B) ReplaceFiles<-B end
      meth get_replacefiles($)
         if @Superman\=unit
         then {@Superman get_replacefiles($)}
         else @ReplaceFiles end
      end
      meth set_keepzombies(B) KeepZombies<-B end
      meth get_keepzombies($)
         if @Superman\=unit
         then {@Superman get_keepzombies($)}
         else @KeepZombies end
      end
      meth set_savedb(B) SaveDB<-B end
      meth get_savedb($)
         if @Superman\=unit
         then {@Superman get_savedb($)}
         else @SaveDB end
      end

      meth set_includedocs(B) IncludeDocs<-B end
      meth get_includedocs($)
         if @Superman\=unit
         then {@Superman get_includedocs($)}
         else @IncludeDocs end
      end
      meth set_includelibs(B) IncludeLibs<-B end
      meth get_includelibs($)
         if @Superman\=unit
         then {@Superman get_includelibs($)}
         else @IncludeLibs end
      end
      meth set_includebins(B) IncludeBins<-B end
      meth get_includebins($)
         if @Superman\=unit
         then {@Superman get_includebins($)}
         else @IncludeBins end
      end

      meth set_extendpackage(B) ExtendPkg<-B end
      meth get_extendpackage($)
         if @Superman\=unit
         then {@Superman get_extendpackage($)}
         else @ExtendPkg end
      end

      meth set_gnu(B) GNU<-B end
      meth get_gnu($)
         if @GNU==unit then
            if @Superman\=unit
            then GNU<-{@Superman get_gnu($)}
            else GNU<-{self exec_check_for_gnu($)} end
         end
         @GNU
      end

      meth set_package(F)
         PackageGiven<-true
         Package<-{Path.expand F}
      end
      meth get_package($)
         if @Package==unit andthen @Superman\=unit then
            Package<-{@Superman get_package($)}
         end
         if @Package==unit then
            raise ozmake(get_package) end
         else @Package end
      end
      meth get_package_given($)
         if @Superman\=unit
         then {@Superman get_package_given($)}
         else @PackageGiven end
      end

      meth set_publishdir(D) PublishDir<-{Path.expand D} end
      meth get_publishdir($)
         if @PublishDir==unit then
            if @Superman\=unit then
               PublishDir<-{@Superman get_publishdir($)}
            else
               PublishDir<-{Path.expand
                            {Path.resolve {self get_prefix($)} 'pkg'}}
            end
         end
         @PublishDir
      end

      meth set_archive(U) Archive<-U end
      meth get_archive($)
         if @Superman\=unit
         then {@Superman get_archive($)}
         else @Archive end
      end

      meth set_linewidth(N) LineWidth<-N end
      meth get_linewidth($)
         if @Superman\=unit
         then {@Superman get_linewidth($)}
         else @LineWidth end
      end

      meth set_no_makefile(B) NoMakefile<-B end
      meth get_no_makefile($)
         if @Superman\=unit
         then {@Superman get_no_makefile($)}
         else @NoMakefile end
      end

      meth set_subdirs(L) Subdirs<-L end
      meth get_subdirs($) @Subdirs end

      meth set_assubdir(F) AsSubdir<-F end
      meth get_assubdir($) @AsSubdir end
      meth set_superman(M) Superman<-M end
      meth get_superman($) @Superman end

      meth get_submans($)
         if @Submans==unit then
            Submans<-{self subdirs_to_managers({self get_subdirs($)} $)}
         end
         @Submans
      end

      meth set_local(B) Local<-B end
      meth get_local($)
         if @Superman\=unit
         then {@Superman get_local($)}
         else @Local end
      end

      meth set_submakefiles(R) Submakefiles<-R end
      meth get_submakefiles($) @Submakefiles end
      meth has_submakefile(D $)
         {HasFeature @Submakefiles {Path.toAtom D}}
      end
      meth get_submakefile(D $)
         @Submakefiles.{Path.toAtom D}
      end

      meth set_includedirs(L) IncludeDirs<-L end
      meth get_includedirs($) @IncludeDirs end
      meth set_librarydirs(L) LibraryDirs<-L end
      meth get_librarydirs($) @LibraryDirs end

      meth extend_resolver
         if @ResolverExtended then skip else
            ResolverExtended<-true
            if @Superman \= unit then
               {@Superman extend_resolver}
            else
               SRC={self get_srcdir($)}
               BLD={self get_builddir($)}
               SEP=[{Property.get 'path.separator'}]
               OZHOME={Property.get 'oz.home'}
            in
               {OS.putEnv 'OZ_SEARCH_LOAD'
                'cache=~/.oz/cache'     #SEP#
                'cache='#OZHOME#'/cache'#SEP#
                'root='#SRC             #SEP#
                'root='#BLD}
               {Resolve.addHandler
                {Resolve.handler.root SRC}}
               {Resolve.addHandler
                {Resolve.handler.root BLD}}
            end
         end
      end
   end
end