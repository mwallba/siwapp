class InvoiceMailer < ApplicationMailer
  add_template_helper TemplatesHelper
  add_template_helper ApplicationHelper

  def email_invoice(invoice)
    @invoice = invoice

    # Getting email template
    email_template = @invoice.get_email_template

    # Rendering the and composing mail content
    pdf_html = render_invoice_html(
      template: @invoice.get_print_template,
      invoice: @invoice
    )

    email_subject = render_invoice_html(
      template: OpenStruct.new(template: email_template.subject),
      invoice: @invoice
    )

    email_body = render_invoice_html(
      template: email_template,
      invoice: @invoice
    )

    attachments["#{@invoice}.pdf"] = @invoice.pdf(pdf_html)

    # Sending the email
    mail(
      from: Settings.company_email,
      to: @invoice.email,
      subject: email_subject,
      body: email_body
    ) do |format|
      format.html {email_body}
    end
  end

  private

  def render_invoice_html(template:, invoice:)
    render_to_string(
      inline: template.template,
      locals: {
        invoice: invoice,
        settings: Settings
      }
    )
  end
end
