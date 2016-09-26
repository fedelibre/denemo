#include <evince-view.h>
#include <errno.h>
#include <math.h>
#include <glib/gstdio.h>
#include "export/print.h"
#include "ui/markup.h"

static GtkWidget *DenemoMarkupArea;
static gboolean
overdraw_print (cairo_t * cr)
{
  gint x, y;
  gint message_height = 50;
 // get_window_position (&x, &y);

  //cairo_translate (cr, -x, -y);

  //cairo_save (cr);

  
  if (Denemo.printstatus->invalid)
  {
      cairo_set_source_rgba (cr, 0.5, 0.0, 0.0, 0.4);
      cairo_set_font_size (cr, 48.0);
      cairo_move_to (cr, 50, message_height);
      cairo_show_text (cr, _( "Cannot Typeset!"));
      cairo_move_to (cr, 50, message_height + 50);
      cairo_set_font_size (cr, 24.0);
      cairo_show_text (cr, _( "Edit the markup in the pane below and then click here"));
      
  } else
  {
      cairo_set_source_rgba (cr, 0.0, 0.5, 0.0, 0.4);
      cairo_set_font_size (cr, 48.0);
      cairo_move_to (cr, 50, message_height);
      cairo_show_text (cr, _( "Click to Preview"));
  }
 return TRUE;
}
   
        
static void
set_printarea_doc (EvDocument * doc)
{
  EvDocumentModel *model;
  model = g_object_get_data (G_OBJECT (DenemoMarkupArea), "model");     //there is no ev_view_get_model(), when there is use it
  if (model == NULL)
    {
      model = ev_document_model_new_with_document (doc);
      ev_view_set_model ((EvView *) DenemoMarkupArea, model);
      g_object_set_data (G_OBJECT (DenemoMarkupArea), "model", model);  //there is no ev_view_get_model(), when there is use it
    }
  else
    {
      g_object_unref (ev_document_model_get_document (model));  //FIXME check if this releases the file lock on windows.s
      ev_document_model_set_document (model, doc);
    }
}

static void
set_printarea (GError ** err)
{
  GFile *file;
  gchar *filename = Denemo.printstatus->printname_pdf[Denemo.printstatus->cycle];
  //g_debug("using %s\n", filename);
  if (Denemo.printstatus->invalid == 0)
    Denemo.printstatus->invalid = (g_file_test (filename, G_FILE_TEST_EXISTS)) ? 0 : 3;
  file = g_file_new_for_commandline_arg (filename);
  //g_free(filename);
  gchar *uri = g_file_get_uri (file);
  g_object_unref (file);
  EvDocument *doc = ev_document_factory_get_document (uri, err);
  //gint x = 0, y = 0, hupper, hlower, vupper, vlower;//store current position for reloading
  //get_window_position(&x, &y, &hupper, &hlower, &vupper, &vlower);
  if (*err)
    {
      g_warning ("Trying to read the pdf file %s gave an error: %s", uri, (*err)->message);
      Denemo.printstatus->invalid = 3;
      gtk_widget_queue_draw (DenemoMarkupArea);
    }
  else
    set_printarea_doc (doc);
  return;
}

void
markupview_finished (G_GNUC_UNUSED GPid pid, gint status, gboolean print)
{
#if GLIB_CHECK_VERSION(2,34,0)
  {
    GError *err = NULL;
    if (!g_spawn_check_exit_status (status, &err))
      g_warning ("Lilypond did not end successfully: %s", err->message);
  }
#endif
  g_spawn_close_pid (Denemo.printstatus->printpid);
  //g_debug("background %d\n", Denemo.printstatus->background);
  if (Denemo.printstatus->background == STATE_NONE)
    {
      process_lilypond_errors ((gchar *) get_printfile_pathbasename ());
    }
  else
    {
      if (LilyPond_stderr != -1)
        close (LilyPond_stderr);
      LilyPond_stderr = -1;
    }
  Denemo.printstatus->printpid = GPID_NONE;
  GError *err = NULL;
  set_printarea (&err);
}

#if GTK_MAJOR_VERSION==3
static gint
markuparea_draw_event (G_GNUC_UNUSED GtkWidget * w, cairo_t * cr)
{
  return overdraw_print (cr);
}
#else
static gint
markuparea_draw_event (GtkWidget * widget, GdkEventExpose * event)
{
  /* Setup a cairo context for rendering and clip to the exposed region. */
  cairo_t *cr = gdk_cairo_create (event->window);
  gdk_cairo_region (cr, event->region);
  cairo_clip (cr);
  overdraw_print (cr);
  cairo_destroy (cr);
  return TRUE;
}
#endif

static GtkWidget *TheTopBox;
static gint
markuparea_button_release (void)
{
   GtkWidget *textbuffer = (GtkWidget*)g_object_get_data (G_OBJECT(TheTopBox), "textbuffer");
   if (textbuffer)
    run_preview (textbuffer);
   return TRUE; 
}


void
install_markup_preview (GtkWidget * top_vbox, gchar *tooltip)
{
  TheTopBox = top_vbox;
  GtkWidget *main_vbox = gtk_vbox_new (FALSE, 1);
  gtk_container_add (GTK_CONTAINER (top_vbox), main_vbox);
  ev_init ();
  DenemoMarkupArea = (GtkWidget *) ev_view_new ();
  GtkWidget *score_and_scroll_box = gtk_scrolled_window_new (NULL, NULL);
  gtk_widget_set_size_request (GTK_WIDGET (score_and_scroll_box), 600, 200);
  gtk_box_pack_start (GTK_BOX (main_vbox), score_and_scroll_box, TRUE, TRUE, 0);  
  gtk_container_add (GTK_CONTAINER (score_and_scroll_box), DenemoMarkupArea);
  gtk_widget_show_all (main_vbox);
  
  
#if GTK_MAJOR_VERSION != 2
  g_signal_connect_after (G_OBJECT (DenemoMarkupArea), "draw", G_CALLBACK (markuparea_draw_event), NULL);
#else
  g_signal_connect_after (G_OBJECT (DenemoMarkupArea), "expose_event", G_CALLBACK (markuparea_draw_event), NULL);
#endif
 //g_signal_connect_after (G_OBJECT (DenemoMarkupArea), "button_press_event", G_CALLBACK (markuparea_button_press), NULL); for some reason this is not received after the start
 
  g_signal_connect_after (G_OBJECT (DenemoMarkupArea), "button_release_event", G_CALLBACK (markuparea_button_release), NULL);



}