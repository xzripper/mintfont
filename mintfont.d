/** 
 * MintFont v1.0.0 - Utility to make installing fonts easier, especially for Linux and Linux Mint.
 * It has features like installing, uninstalling, checking fonts for installation, et cetera.
 */

import std.stdio : writeln;
import std.file : dirEntries, remove, exists, SpanMode, DirEntry, FileException;
import std.process : execute;
import std.algorithm : endsWith;

const string G_MFONT_VERSION = "v1.0.0";

const string G_MFINSTALL = "install";
const string G_MFUNINSTALL = "uninstall";
const string G_MFINSTALLED = "installed";
const string G_MFHELP = "help";

const string G_FPATH = "/usr/share/fonts/";

const string[] G_FCREFR = [ "sudo", "fc-cache", "-fv" ];

bool _FontExists( string p_Dir, string p_Font )
{
    foreach( DirEntry t_DEntry; dirEntries( p_Dir, SpanMode.depth ) ) {
        if( endsWith( t_DEntry.name(), p_Font ) && t_DEntry.isFile() ) {
            return true;
        }
    }

    return false;
}

string _FindFont( string p_Dir, string p_Font )
{
    foreach( DirEntry t_DEntry; dirEntries( p_Dir, SpanMode.depth ) ) {
        if( endsWith( t_DEntry.name(), p_Font ) && t_DEntry.isFile() ) {
            return t_DEntry.name();
        }
    }

    return null;
}

string[] _FFMVCommand( string p_Font )
{
    return [ "sudo", "mv", p_Font, G_FPATH ];
}

void _WarnNonTTFOTF( string p_Font )
{
    if( !endsWith( p_Font, ".ttf" ) && !endsWith( p_Font, ".otf" ) ) {
        writeln( "WARNING: Font is not TTF or OTF." );
    }
}

void main( string[] p_InArgs )
{
    p_InArgs = p_InArgs[1..$];

    writeln( "MintFont ", G_MFONT_VERSION, " (`mintfont help`)" );

    if( p_InArgs.length <= 0 ) {
        writeln( "INFO: No tasks to do." );

        return;
    }

    if( p_InArgs[0] == G_MFINSTALL ) {
        if( p_InArgs.length <= 1 ) {
            writeln( "ERROR: Missing FONT[1] parameter." );
            writeln( "AUTOCORRECTION: mintfont install -> [FONT] <-" );

            return;
        }

        if( !exists( p_InArgs[1] ) ) {
            writeln( "ERROR: Can't install font: not found." );

            return;
        }

        _WarnNonTTFOTF( p_InArgs[1] );

        writeln( "INFO: Installing font..." );
        writeln( "WARNING: Performing sudo-mode operation; a password may be requested." );

        auto t_FFMOut = execute( _FFMVCommand( p_InArgs[1] ) );

        writeln( "INFO: FFMV finished; Status code: ", t_FFMOut.status );
        writeln( "INFO: Refreshing font cache..." );

        auto t_FCRefrOut = execute( G_FCREFR );

        writeln( "INFO: Cache refreshing status code: ", t_FCRefrOut.status );
        writeln( "INFO: Font installed." );
    } else if( p_InArgs[0] == G_MFUNINSTALL ) {
        if( p_InArgs.length <= 1) {
            writeln( "ERROR: Missing FONT[1] parameter." );
            writeln( "AUTOCORRECTION: mintfont uninstall -> [FONT] <-" );

            return;
        }

        if( !_FontExists( G_FPATH, p_InArgs[1] ) ) {
            writeln( "ERROR: The font could not be found to uninstall." );

            return;
        }

        string t_FPath = _FindFont( G_FPATH, p_InArgs[1] );

        if( t_FPath == null ) {
            writeln( "ERROR: Can't find font location." );

            return;
        }

        writeln( "INFO: Removing font..." );

        try {
            remove( t_FPath );
        } catch(FileException exc_RemovalError) {
            writeln( "ERROR: Can't remove font: no permission (`sudo` required)." );

            return;
        }

        writeln( "INFO: Refreshing font cache..." );

        auto t_FCRefrOut = execute( G_FCREFR );

        writeln( "INFO: Cache refreshing status code: ", t_FCRefrOut.status );
        writeln( "INFO: Font uninstalled." );
    } else if( p_InArgs[0] == G_MFINSTALLED ) {
        if( p_InArgs.length <= 1 ) {
            writeln( "ERROR: Missing FONT[1] parameter." );
            writeln( "AUTOCORRECTION: mintfont installed -> [FONT] <-" );

            return;
        }

        writeln( "INFO: ", _FontExists( G_FPATH, p_InArgs[1] ) ? "Font is already installed." : "Font is not installed." );
    } else if( p_InArgs[0] == G_MFHELP ) {
        writeln("mintfont install [FONT] - Install a font for all users.
mintfont uninstall [FONT] - Uninstall a font for all users.
mintfont installed [FONT] - Check is font installed for all users.
mintfont help - MintFont help.");
    } else {
        writeln( "ERROR: Unknown command." );
    }
}
